import 'package:get_it/get_it.dart';
import 'models/services/heart_local_driver.dart';
import 'models/services/heart_fill_service.dart';
import 'models/repository/heart_repository.dart';
import 'models/repository/heart_repository_impl.dart';
import 'viewmodels/heart_view_model.dart';
import 'models/services/local_storage.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // 1️⃣ Register low-level services/drivers
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage());
  sl.registerLazySingleton<HeartLocalDriver>(
    () => HeartLocalDriver(sl<LocalStorage>()),
  );
  sl.registerLazySingleton<HeartFillService>(() => HeartFillService());

  // 2️⃣ Register repository with its dependency
  sl.registerLazySingleton<HeartRepository>(
    () => HeartRepositoryImpl(sl<HeartLocalDriver>()),
  );

  // 3️⃣ Register ViewModel (depends on repo + filler)
  sl.registerFactory<HeartViewModel>(
    () => HeartViewModel(repo: sl(), filler: sl()),
  );
}
