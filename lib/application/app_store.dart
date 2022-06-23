import 'package:oees/application/auth_app.dart';
import 'package:oees/application/common_app.dart';
import 'package:oees/application/device_app.dart';
import 'package:oees/application/device_data_app.dart';
import 'package:oees/application/downtime_app.dart';
import 'package:oees/application/downtime_preset_app.dart';
import 'package:oees/application/job_app.dart';
import 'package:oees/application/line_app.dart';
import 'package:oees/application/plant_app.dart';
import 'package:oees/application/shift_app.dart';
import 'package:oees/application/sku_app.dart';
import 'package:oees/application/sku_speed_app.dart';
import 'package:oees/application/task_app.dart';
import 'package:oees/application/user_app.dart';
import 'package:oees/application/user_role_access_app.dart';
import 'package:oees/application/user_role_app.dart';
import 'package:oees/infrastructure/persistance/repo_store.dart';

AppStore appStore = AppStore();

class AppStore {
  final authApp = AuthApp(authRepository: repoStore.authRepo);
  final commonApp = CommonApp(commonRepository: repoStore.commonRepo);
  final deviceApp = DeviceApp(deviceRepository: repoStore.deviceRepo);
  final deviceDataApp = DeviceDataApp(deviceDataRepository: repoStore.deviceDataRepo);
  final downtimeApp = DowntimeApp(downtimeRepository: repoStore.downtimeRepo);
  final downtimePresetApp = DowntimePresetApp(downtimePresetRepository: repoStore.downtimePresetRepo);
  final jobApp = JobApp(jobRepository: repoStore.jobRepo);
  final lineApp = LineApp(lineRepository: repoStore.lineRepo);
  final plantApp = PlantApp(plantRepository: repoStore.plantRepo);
  final shiftApp = ShiftApp(shiftRepository: repoStore.shiftRepo);
  final skuApp = SKUApp(skuRepository: repoStore.skuRepo);
  final skuSpeedApp = SKUSpeedApp(skuSpeedRepository: repoStore.skuSpeedRepo);
  final taskApp = TaskApp(taskRepository: repoStore.taskRepo);
  final userApp = UserApp(userRepository: repoStore.userRepo);
  final userRoleApp = UserRoleApp(userRoleRepository: repoStore.userRoleRepo);
  final userRoleAccessApp = UserRoleAccessApp(userRoleAccessRepository: repoStore.userRoleAccessRepo);
}
