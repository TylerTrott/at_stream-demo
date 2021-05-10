import 'dart:convert';
import 'dart:core';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:stream_demo/utils/at_conf.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:at_commons/at_commons.dart';
import 'package:at_demo_data/at_demo_data.dart' as at_demo_data;
import 'package:at_client/src/util/encryption_util.dart'; // TODO export this file for its usage PR created

class ServerDemoService {
  static final ServerDemoService _singleton = ServerDemoService._internal();

  ServerDemoService._internal();

  factory ServerDemoService.getInstance() => _singleton;

  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  Map<String, AtClientService> atClientServiceMap = {};
  String atSign;

  sync() async => await getAtClientForAtsign().getSyncManager().sync();

  AtClientImpl getAtClientForAtsign({String atsign}) {
    atsign ??= atSign;
    if (atClientServiceMap.containsKey(atsign)) {
      return atClientServiceMap[atsign].atClient;
    }
    return null;
  }

  AtClientService getClientServiceForAtSign(String atsign) {
    if (atClientServiceMap.containsKey(atsign)) {
      return atClientServiceMap[atsign];
    }
    final service = AtClientService();
    return service;
  }

  Future<AtClientPreference> getAtClientPreference({String cramSecret}) async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    final path = appDocumentDirectory.path;
    final _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..cramSecret = cramSecret
      ..namespace = AtConfig.namespace
      ..syncStrategy = SyncStrategy.IMMEDIATE
      ..rootDomain = AtConfig.root
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  checkAtSignStatus(String atsign) async {
    final atStatusImpl = AtStatusImpl(rootUrl: AtConfig.root);
    final status = await atStatusImpl.get(atsign);
    return status.serverStatus;
  }

  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = getClientServiceForAtSign(atsign);
    final atClientPreference = await getAtClientPreference();
    final result = await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference, atsign: atsign);
    atSign = atsign == null ? await this.getAtSign() : atsign;
    atClientServiceMap.putIfAbsent(atSign, () => atClientServiceInstance);
    sync();
    return result;
  }

  ///Returns `false` if fails in authenticating [atsign] with [cramSecret]/[privateKey].
  Future<bool> authenticate(
    String atsign, {
    String privateKey,
    String jsonData,
    String decryptKey,
  }) async {
    final atsignStatus = await checkAtSignStatus(atsign);
    if (atsignStatus != ServerStatus.teapot &&
        atsignStatus != ServerStatus.activated) {
      throw atsignStatus;
    }
    final atClientPreference = await getAtClientPreference();
    final result = await atClientServiceInstance.authenticate(
        atsign, atClientPreference,
        jsonData: jsonData, decryptKey: decryptKey);
    atSign = atsign;
    atClientServiceMap.putIfAbsent(atSign, () => atClientServiceInstance);
    await sync();
    return result;
  }

  String encryptKeyPairs(String atsign) {
    final encryptedPkamPublicKey = EncryptionUtil.encryptValue(
        at_demo_data.pkamPublicKeyMap[atsign], at_demo_data.aesKeyMap[atsign]);
    final encryptedPkamPrivateKey = EncryptionUtil.encryptValue(
        at_demo_data.pkamPrivateKeyMap[atsign], at_demo_data.aesKeyMap[atsign]);
    final aesencryptedPkamPublicKey = EncryptionUtil.encryptValue(
        at_demo_data.encryptionPublicKeyMap[atsign],
        at_demo_data.aesKeyMap[atsign]);
    final aesencryptedPkamPrivateKey = EncryptionUtil.encryptValue(
        at_demo_data.encryptionPrivateKeyMap[atsign],
        at_demo_data.aesKeyMap[atsign]);
    var aesEncryptedKeys = {};
    aesEncryptedKeys[BackupKeyConstants.AES_PKAM_PUBLIC_KEY] =
        encryptedPkamPublicKey;

    aesEncryptedKeys[BackupKeyConstants.AES_PKAM_PRIVATE_KEY] =
        encryptedPkamPrivateKey;

    aesEncryptedKeys[BackupKeyConstants.AES_ENCRYPTION_PUBLIC_KEY] =
        aesencryptedPkamPublicKey;

    aesEncryptedKeys[BackupKeyConstants.AES_ENCRYPTION_PRIVATE_KEY] =
        aesencryptedPkamPrivateKey;

    final keyString = jsonEncode(Map<String, String>.from(aesEncryptedKeys));
    return keyString;
  }

  Future<String> get(AtKey atKey) async {
    final result = await getAtClientForAtsign().get(atKey);
    return result.value;
  }

  Future<bool> put(AtKey atKey, String value) async =>
      await getAtClientForAtsign().put(atKey, value);

  Future<bool> delete(AtKey atKey) async =>
      await getAtClientForAtsign().delete(atKey);

  Future<List<AtKey>> getAtKeys({String sharedBy}) async =>
      await getAtClientForAtsign().getAtKeys(
        regex: AtConfig.namespace,
        sharedBy: sharedBy,
      );

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await atClientServiceInstance.getAtSign();
  }
}

class BackupKeyConstants {
  static const String AES_PKAM_PUBLIC_KEY = 'aesPkamPublicKey';
  static const String AES_PKAM_PRIVATE_KEY = 'aesPkamPrivateKey';
  static const String AES_ENCRYPTION_PUBLIC_KEY = 'aesEncryptPublicKey';
  static const String AES_ENCRYPTION_PRIVATE_KEY = 'aesEncryptPrivateKey';
}
