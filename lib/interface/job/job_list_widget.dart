import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/job.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/lists/job_list.dart';
import 'package:oees/interface/common/super_widget/super_widget.dart';

class JobListWidget extends StatefulWidget {
  const JobListWidget({Key? key}) : super(key: key);

  @override
  State<JobListWidget> createState() => _JobListWidgetState();
}

class _JobListWidgetState extends State<JobListWidget> {
  bool isLoading = true;
  List<Job> jobs = [];

  @override
  void initState() {
    getJOBs();
    super.initState();
  }

  Future<void> getJOBs() async {
    jobs = [];
    await appStore.jobApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          Job job = Job.fromJSON(item);
          jobs.add(job);
        }
      }
    });
    setState(() {
      isLoading = false;
    });
    jobs.sort(((a, b) => a.code.compareTo(b.code)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkTheme,
      builder: (context, darkTheme, child) {
        return isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : SuperWidget(
                childWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All JOBs",
                      style: TextStyle(
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 50.0,
                    ),
                    jobs.isNotEmpty
                        ? JobList(jobs: jobs)
                        : Text(
                            "No JOBs Found",
                            style: TextStyle(
                              color: isDarkTheme.value ? foregroundColor : backgroundColor,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                ),
                errorCallback: () {},
              );
      },
    );
  }
}
