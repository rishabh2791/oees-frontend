import 'package:flutter/material.dart';
import 'package:oees/domain/entity/shift.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class ShiftList extends StatefulWidget {
  final List<Shift> shifts;
  const ShiftList({
    Key? key,
    required this.shifts,
  }) : super(key: key);

  @override
  State<ShiftList> createState() => _ShiftListState();
}

class _ShiftListState extends State<ShiftList> {
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
          widget.shifts.sort((a, b) => a.code.compareTo(b.code));
        } else {
          widget.shifts.sort((a, b) => b.code.compareTo(a.code));
        }
        break;
      case 1:
        if (ascending) {
          widget.shifts.sort((a, b) => a.description.compareTo(b.description));
        } else {
          widget.shifts.sort((a, b) => b.description.compareTo(a.description));
        }
        break;
      case 2:
        if (ascending) {
          widget.shifts.sort((a, b) => a.startTime.compareTo(b.startTime));
        } else {
          widget.shifts.sort((a, b) => b.startTime.compareTo(a.startTime));
        }
        break;
      case 3:
        if (ascending) {
          widget.shifts.sort((a, b) => a.endTime.compareTo(b.endTime));
        } else {
          widget.shifts.sort((a, b) => b.endTime.compareTo(a.endTime));
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
          height: widget.shifts.length <= 25
              ? 156 + widget.shifts.length * 56
              : 156 + 25 * 56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cardColor:
                        isDarkTheme.value ? backgroundColor : foregroundColor,
                    dividerColor: isDarkTheme.value
                        ? foregroundColor.withOpacity(0.25)
                        : backgroundColor.withOpacity(0.25),
                    textTheme: TextTheme(
                      bodySmall: TextStyle(
                        color: isDarkTheme.value
                            ? foregroundColor
                            : backgroundColor,
                      ),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      PaginatedDataTable(
                        arrowHeadColor: isDarkTheme.value
                            ? foregroundColor
                            : backgroundColor,
                        showCheckboxColumn: false,
                        showFirstLastButtons: true,
                        sortAscending: sort,
                        sortColumnIndex: sortingColumnIndex,
                        columnSpacing: 20.0,
                        columns: [
                          DataColumn(
                            label: Text(
                              "Shift Code",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value
                                    ? foregroundColor
                                    : backgroundColor,
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
                              "Shift Description",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: isDarkTheme.value
                                    ? foregroundColor
                                    : backgroundColor,
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
                                color: isDarkTheme.value
                                    ? foregroundColor
                                    : backgroundColor,
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
                                color: isDarkTheme.value
                                    ? foregroundColor
                                    : backgroundColor,
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
                        source: _DataSource(context, widget.shifts),
                        rowsPerPage: widget.shifts.length > 25
                            ? 25
                            : widget.shifts.length,
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
  _DataSource(this.context, this._shifts) {
    _shifts = _shifts;
  }

  final BuildContext context;
  List<Shift> _shifts;
  TextEditingController ipAddressController = TextEditingController();

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final shift = _shifts[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            shift.code,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            shift.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            shift.startTime,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            shift.endTime,
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
  int get rowCount => _shifts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
