import 'package:flutter/material.dart';
import 'package:oees/application/app_store.dart';
import 'package:oees/domain/entity/line.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class LineList extends StatefulWidget {
  final List<Line> lines;
  const LineList({
    Key? key,
    required this.lines,
  }) : super(key: key);

  @override
  State<LineList> createState() => _LineListState();
}

class _LineListState extends State<LineList> {
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
          widget.lines.sort((a, b) => a.code.compareTo(b.code));
        } else {
          widget.lines.sort((a, b) => b.code.compareTo(a.code));
        }
        break;
      case 1:
        if (ascending) {
          widget.lines.sort((a, b) => a.name.compareTo(b.name));
        } else {
          widget.lines.sort((a, b) => b.name.compareTo(a.name));
        }
        break;
      case 2:
        if (ascending) {
          widget.lines.sort((a, b) => a.ipAddress.compareTo(b.ipAddress));
        } else {
          widget.lines.sort((a, b) => b.ipAddress.compareTo(a.ipAddress));
        }
        break;
      case 3:
        if (ascending) {
          widget.lines.sort((a, b) => a.speedType.compareTo(b.speedType));
        } else {
          widget.lines.sort((a, b) => b.speedType.compareTo(a.speedType));
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
          height: widget.lines.length <= 25
              ? 156 + widget.lines.length * 56
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
                              "Line Code",
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
                              "Line Name",
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
                              "IP Address",
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
                              "Speed Type",
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
                        source: _DataSource(context, widget.lines),
                        rowsPerPage:
                            widget.lines.length > 25 ? 25 : widget.lines.length,
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
  _DataSource(this.context, this._lines) {
    _lines = _lines;
  }

  final BuildContext context;
  List<Line> _lines;
  TextEditingController ipAddressController = TextEditingController();

  Future<void> _assignIPAddress(BuildContext context, Line line) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign IP Address'),
          content: TextField(
            controller: ipAddressController,
            decoration: const InputDecoration(hintText: "Assign IP Address"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Assign'),
              onPressed: () async {
                var ipAddress = ipAddressController.text;
                if (ipAddress == "" || ipAddress.isEmpty) {
                } else {
                  Map<String, dynamic> update = {
                    "ip_address": ipAddressController.text
                  };
                  await appStore.lineApp.update(line.id, update).then(
                    (response) async {
                      if (response.containsKey("status") &&
                          response["status"]) {
                        line.ipAddress = ipAddressController.text;
                        await storage!.setString("line_id", line.id);
                      } else {
                        line.ipAddress = "Not Assigned.";
                      }
                      Navigator.of(context).pop();
                      notifyListeners();
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _unAssignIPAddress(BuildContext context, Line line) async {
    Map<String, dynamic> update = {"ip_address": " "};
    await appStore.lineApp.update(line.id, update).then(
      (response) async {
        if (response.containsKey("status") && response["status"]) {
          line.ipAddress = " ";
          await storage!.remove("line_id");
        } else {
          line.ipAddress = "Not Assigned.";
        }
        notifyListeners();
      },
    );
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final line = _lines[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            line.code,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            line.name,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          line.ipAddress.isEmpty || line.ipAddress == " "
              ? Text(
                  "Assign",
                  style: TextStyle(
                    fontSize: 16.0,
                    color:
                        isDarkTheme.value ? foregroundColor : backgroundColor,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : Text(
                  line.ipAddress,
                  style: TextStyle(
                    fontSize: 16.0,
                    color:
                        isDarkTheme.value ? foregroundColor : backgroundColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
          onTap: line.ipAddress.isEmpty || line.ipAddress == " "
              ? () {
                  _assignIPAddress(context, line);
                }
              : () {
                  _unAssignIPAddress(context, line);
                },
        ),
        DataCell(
          Text(
            line.speedType == 1 ? "Low" : "High",
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
  int get rowCount => _lines.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
