import 'package:flutter/material.dart';
import 'package:oees/domain/entity/task_batch.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class TaskBatchesList extends StatefulWidget {
  final List<TaskBatch> taskBatches;
  final Map<String, dynamic> batchUnits;
  const TaskBatchesList({
    Key? key,
    required this.taskBatches,
    required this.batchUnits,
  }) : super(key: key);

  @override
  State<TaskBatchesList> createState() => _TaskBatchesListState();
}

class _TaskBatchesListState extends State<TaskBatchesList> {
  bool sort = true, ascending = true;
  int sortingColumnIndex = 0;

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
          widget.taskBatches.sort((a, b) => a.batchNumber.compareTo(b.batchNumber));
        } else {
          widget.taskBatches.sort((a, b) => b.batchNumber.compareTo(a.batchNumber));
        }
        break;
      case 1:
        if (ascending) {
          widget.taskBatches.sort((a, b) => a.startTime.compareTo(b.startTime));
        } else {
          widget.taskBatches.sort((a, b) => b.startTime.compareTo(a.startTime));
        }
        break;
      case 2:
        if (ascending) {
          widget.taskBatches.sort((a, b) => a.endTime.compareTo(b.endTime));
        } else {
          widget.taskBatches.sort((a, b) => b.endTime.compareTo(a.endTime));
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
          height: widget.taskBatches.length <= 25 ? 156 + widget.taskBatches.length * 56 : 156 + 25 * 56,
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
                              "Batch#",
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
                              "Batch Size (KG)",
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
                              "Production",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value ? foregroundColor : backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                        source: _DataSource(context, widget.taskBatches, widget.batchUnits),
                        rowsPerPage: widget.taskBatches.length > 25 ? 25 : widget.taskBatches.length,
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
  _DataSource(this.context, this._taskBatches, this._batchUnits) {
    _taskBatches = _taskBatches;
    _batchUnits = _batchUnits;
  }

  final BuildContext context;
  List<TaskBatch> _taskBatches;
  Map<String, dynamic> _batchUnits;
  TextEditingController ipAddressController = TextEditingController();

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final taskBatch = _taskBatches[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            taskBatch.batchNumber,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            taskBatch.batchSize.toStringAsFixed(1).replaceAllMapped(reg, (Match match) => '${match[1]},'),
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            taskBatch.startTime.toLocal().toString().toString().split(".")[0].substring(0, 16),
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            taskBatch.endTime.difference(DateTime.parse("2099-12-31T23:59:59Z").toLocal()).inSeconds < 0
                ? taskBatch.endTime.toLocal().toString().split(".")[0].substring(0, 16)
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
            numberFormat.format(_batchUnits[taskBatch.id] ?? 0),
            // _batchUnits[taskBatch.id].toStringAsFixed(0),
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
  int get rowCount => _taskBatches.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
