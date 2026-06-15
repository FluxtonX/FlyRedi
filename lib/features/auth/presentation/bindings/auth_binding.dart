import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // 1. Core Networking
    Get.lazyPut<DioClient>(() => DioClient(), fenix: true);

    // 2. Data Sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(dioClient: Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSource(storageService: Get.find<StorageService>()),
      fenix: true,
    );

    // 3. Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
      fenix: true,
    );

    // 4. Global Auth Controller
    Get.put<AuthController>(
      AuthController(
        authRepository: Get.find<AuthRepository>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
      permanent: true,
    );
  }
}
