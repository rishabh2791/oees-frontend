import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/domain/entity/downtime_preset.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/user_action_button.dart';
import 'package:oees/interface/downtime/downtime_update_widget.dart';

class DowntimeList extends StatefulWidget {
  final List<Downtime> downtimes;
  final MyCallback notifyParent;
  final String action;
  const DowntimeList({
    Key? key,
    required this.downtimes,
    required this.notifyParent,
    this.action = "create",
  }) : super(key: key);

  @override
  State<DowntimeList> createState() => _DowntimeListState();
}

class _DowntimeListState extends State<DowntimeList> {
  bool sort = true, ascending = true, isLoading = true;
  int sortingColumnIndex = 0;
  List<DowntimePreset> downtimePresets = [];
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    getPresetDowntimes();
    widget.downtimes.sort((a, b) {
      String sortParama = a.startTime.toString() + a.description;
      String sortParamb = b.startTime.toString() + b.description;
      return sortParamb.compareTo(sortParama);
    });
    // widget.downtimes.sort(((a, b) => a.description.compareTo(b.description)));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPresetDowntimes() async {
    await appStore.downtimePresetApp.list({}).then((response) {
      if (response.containsKey("status") && response["status"]) {
        for (var item in response["payload"]) {
          DowntimePreset downtimePreset = DowntimePreset.fromJSON(item);
          downtimePresets.add(downtimePreset);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Unable to get Preset Downtimes.";
          isError = true;
        });
      }
    });
  }

  onSortColum(int columnIndex, bool ascending) {
    switch (columnIndex) {
      case 0:
        if (ascending) {
          widget.downtimes.sort((a, b) => a.description.compareTo(b.description));
        } else {
          widget.downtimes.sort((a, b) => b.description.compareTo(a.description));
        }
        break;
      case 1:
        if (ascending) {
          widget.downtimes.sort((a, b) => a.startTime.compareTo(b.startTime));
        } else {
          widget.downtimes.sort((a, b) => b.startTime.compareTo(a.startTime));
        }
        break;
      case 2:
        if (ascending) {
          widget.downtimes.sort((a, b) => a.endTime.compareTo(b.endTime));
        } else {
          widget.downtimes.sort((a, b) => b.endTime.compareTo(a.endTime));
        }
        break;
      case 3:
        if (ascending) {
          widget.downtimes.sort((a, b) {
            String typeA = a.controlled
                ? "Controlled"
                : a.planned
                    ? "Planned"
                    : "Unplanned";
            String typeB = b.controlled
                ? "Controlled"
                : b.planned
                    ? "Planned"
                    : "Unplanned";
            return typeA.compareTo(typeB);
          });
        } else {
          widget.downtimes.sort((a, b) {
            String typeA = a.controlled
                ? "Controlled"
                : a.planned
                    ? "Planned"
                    : "Unplanned";
            String typeB = b.controlled
                ? "Controlled"
                : b.planned
                    ? "Planned"
                    : "Unplanned";
            return typeB.compareTo(typeA);
          });
        }
        break;
      case 4:
        if (ascending) {
          widget.downtimes.sort(((a, b) {
            int aDowntime =
                a.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0 ? a.endTime.difference(a.startTime).inMinutes : DateTime.now().toLocal().difference(a.startTime).inMinutes;
            int bDowntime =
                b.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0 ? b.endTime.difference(b.startTime).inMinutes : DateTime.now().toLocal().difference(b.startTime).inMinutes;
            return aDowntime.compareTo(bDowntime);
          }));
        } else {
          widget.downtimes.sort(((a, b) {
            int aDowntime =
                a.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0 ? a.endTime.difference(a.startTime).inMinutes : DateTime.now().toLocal().difference(a.startTime).inMinutes;
            int bDowntime =
                b.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0 ? b.endTime.difference(b.startTime).inMinutes : DateTime.now().toLocal().difference(b.startTime).inMinutes;
            return bDowntime.compareTo(aDowntime);
          }));
        }
        break;
      default:
        break;
    }
  }

  Widget listDetailsWidget() {
    return BaseWidget(
      builder: (context, sizeInfo) {
        return isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                  color: isDarkTheme.value ? backgroundColor : foregroundColor,
                ),
              )
            : Container(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                width: sizeInfo.screenSize.width,
                height: widget.downtimes.length <= 25 ? 156 + widget.downtimes.length * 56 : 156 + 25 * 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          cardColor: isDarkTheme.value ? backgroundColor : foregroundColor,
                          dividerColor: isDarkTheme.value ? foregroundColor.withOpacity(0.25) : backgroundColor.withOpacity(0.25),
                          textTheme: TextTheme(
                            bodySmall: TextStyle(
                              color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            ),
                          ),
                        ),
                        child: ListView(
                          controller: scrollController,
                          children: [
                            PaginatedDataTable(
                              arrowHeadColor: isDarkTheme.value ? foregroundColor : backgroundColor,
                              showCheckboxColumn: false,
                              showFirstLastButtons: true,
                              sortAscending: sort,
                              sortColumnIndex: sortingColumnIndex,
                              columnSpacing: 20.0,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    "Downtime",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                      sortingColumnIndex = columnIndex;
                                    });
                                    onSortColum(columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(
                                    "Start Time",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                      sortingColumnIndex = columnIndex;
                                    });
                                    onSortColum(columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(
                                    "End Time",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                      sortingColumnIndex = columnIndex;
                                    });
                                    onSortColum(columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(
                                    "Type",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                      sortingColumnIndex = columnIndex;
                                    });
                                    onSortColum(columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(
                                    "Duration (Min)",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sort = !sort;
                                      sortingColumnIndex = columnIndex;
                                    });
                                    onSortColum(columnIndex, ascending);
                                  },
                                ),
                                getAccessCode("tasks", widget.action) == "1"
                                    ? DataColumn(
                                        label: Text(
                                          "Update",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            sort = !sort;
                                            sortingColumnIndex = columnIndex;
                                          });
                                          onSortColum(columnIndex, ascending);
                                        },
                                      )
                                    : DataColumn(
                                        label: Text(
                                          " ",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            sort = !sort;
                                            sortingColumnIndex = columnIndex;
                                          });
                                          onSortColum(columnIndex, ascending);
                                        },
                                      ),
                              ],
                              source: _DataSource(context, widget.downtimes, widget.notifyParent, widget.action, downtimePresets),
                              rowsPerPage: widget.downtimes.length > 25 ? 25 : widget.downtimes.length,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                  ],
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return listDetailsWidget();
  }
}

class _DataSource extends DataTableSource {
  _DataSource(this.context, this._downtimes, this._notifyParent, this._action, this._downtimePresets) {
    _downtimes = _downtimes;
    _notifyParent = _notifyParent;
    _action = _action;
    _downtimePresets = _downtimePresets;
  }

  final BuildContext context;
  List<Downtime> _downtimes;
  List<DowntimePreset> _downtimePresets;
  Function _notifyParent;
  String _action;
  TextEditingController downtimeController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context, Downtime downtime) async {
    return showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: Container(
            color: Colors.white.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: DowntimeUpdateWidget(
                downtime: downtime,
                notifyParent: _notifyParent,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final downtime = _downtimes[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          downtime.description.isEmpty && downtime.preset.isEmpty
              ? const Text(" ")
              : downtime.description.isEmpty
                  ? Text(
                      _downtimePresets.firstWhere((element) => element.id == downtime.preset).description,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  : downtime.preset.isEmpty
                      ? Text(
                          downtime.description,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                      : Text(
                          _downtimePresets.firstWhere((element) => element.id == downtime.preset).description + " - " + downtime.description,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: isDarkTheme.value ? foregroundColor : backgroundColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
        ),
        DataCell(
          Text(
            downtime.startTime.toLocal().toString().substring(0, 16),
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            downtime.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0 ? downtime.endTime.toLocal().toString().substring(0, 16) : "",
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            downtime.controlled
                ? "Controlled"
                : downtime.planned
                    ? "Planned"
                    : "Unplanned",
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            downtime.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
                ? downtime.endTime.difference(downtime.startTime).inMinutes.toString().replaceAllMapped(reg, (Match match) => '${match[1]},')
                : DateTime.now().toLocal().difference(downtime.startTime).inMinutes.toString().replaceAllMapped(reg, (Match match) => '${match[1]},'),
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        getAccessCode(
                  "tasks",
                  _action,
                ) ==
                "1"
            ? DataCell(
                TextButton(
                  onPressed: () {
                    _displayTextInputDialog(context, downtime);
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Text(
                      "Update",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              )
            : (downtime.description == "" && downtime.preset == "")
                ? DataCell(
                    TextButton(
                      onPressed: () {
                        _displayTextInputDialog(context, downtime);
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  )
                : DataCell(
                    Text(
                      " ",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
      ],
    );
  }

  @override
  int get rowCount => _downtimes.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
