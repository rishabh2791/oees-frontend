import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oees/domain/entity/downtime.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/downtime/downtime_update_widget.dart';

class DowntimeList extends StatefulWidget {
  final List<Downtime> downtimes;
  final Function notifyParent;
  const DowntimeList({
    Key? key,
    required this.downtimes,
    required this.notifyParent,
  }) : super(key: key);

  @override
  State<DowntimeList> createState() => _DowntimeListState();
}

class _DowntimeListState extends State<DowntimeList> {
  bool sort = true, ascending = true;
  int sortingColumnIndex = 0;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          widget.downtimes.sort(((a, b) {
            int aDowntime = a.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
                ? a.endTime.difference(a.startTime).inMinutes
                : DateTime.now().toLocal().difference(a.startTime).inMinutes;
            int bDowntime = b.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
                ? b.endTime.difference(b.startTime).inMinutes
                : DateTime.now().toLocal().difference(b.startTime).inMinutes;
            return aDowntime.compareTo(bDowntime);
          }));
        } else {
          widget.downtimes.sort(((a, b) {
            int aDowntime = a.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
                ? a.endTime.difference(a.startTime).inMinutes
                : DateTime.now().toLocal().difference(a.startTime).inMinutes;
            int bDowntime = b.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z")).inSeconds < 0
                ? b.endTime.difference(b.startTime).inMinutes
                : DateTime.now().toLocal().difference(b.startTime).inMinutes;
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
        return Container(
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
                      caption: TextStyle(
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
                        ],
                        source: _DataSource(context, widget.downtimes, widget.notifyParent),
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
  _DataSource(this.context, this._downtimes, this._notifyParent) {
    _downtimes = _downtimes;
    _notifyParent = _notifyParent;
  }

  final BuildContext context;
  List<Downtime> _downtimes;
  Function _notifyParent;
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
          downtime.description == ""
              ? TextButton(
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
                )
              : Text(
                  downtime.description,
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
            downtime.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0
                ? downtime.endTime.toLocal().toString().substring(0, 16)
                : "",
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
