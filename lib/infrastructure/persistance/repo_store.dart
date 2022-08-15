import 'package:oees/infrastructure/persistance/auth_repo.dart';
import 'package:oees/infrastructure/persistance/common_repo.dart';
import 'package:oees/infrastructure/persistance/device_data_repo.dart';
import 'package:oees/infrastructure/persistance/device_repo.dart';
import 'package:oees/infrastructure/persistance/downtime_preset_repo.dart';
import 'package:oees/infrastructure/persistance/downtime_repo.dart';
import 'package:oees/infrastructure/persistance/job_repo.dart';
import 'package:oees/infrastructure/persistance/line_repo.dart';
import 'package:oees/infrastructure/persistance/shift_repo.dart';
import 'package:oees/infrastructure/persistance/sku_repo.dart';
import 'package:oees/infrastructure/persistance/task_batch_repo.dart';
import 'package:oees/infrastructure/persistance/task_repo.dart';
import 'package:oees/infrastructure/persistance/user_repo.dart';
import 'package:oees/infrastructure/persistance/user_role_access_repo.dart';
import 'package:oees/infrastructure/persistance/user_role_repo.dart';

RepoStore repoStore = RepoStore();

class RepoStore {
  final authRepo = AuthRepo();
  final commonRepo = CommonRepo();
  final deviceRepo = DeviceRepo();
  final deviceDataRepo = DeviceDataRepo();
  final downtimeRepo = DowntimeRepo();
  final downtimePresetRepo = DowntimePresetRepo();
  final jobRepo = JobRepo();
  final lineRepo = LineRepo();
  final shiftRepo = ShiftRepo();
  final skuRepo = SKURepo();
  final taskRepo = TaskRepo();
  final taskBatchRepo = TaskBatchRepo();
  final userRoleRepo = UserRoleRepo();
  final userRepo = UserRepo();
  final userRoleAccessRepo = UserRoleAccessRepo();
}
