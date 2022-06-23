import 'package:flutter/material.dart';
import 'package:oees/domain/entity/device.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class DeviceList extends StatefulWidget {
  final List<Device> devices;
  const DeviceList({
    Key? key,
    required this.devices,
  }) : super(key: key);

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
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
          widget.devices.sort((a, b) => a.deviceType.compareTo(b.deviceType));
        } else {
          widget.devices.sort((a, b) => b.deviceType.compareTo(a.deviceType));
        }
        break;
      case 1:
        if (ascending) {
          widget.devices.sort((a, b) => a.line.plant.description.compareTo(b.line.plant.description));
        } else {
          widget.devices.sort((a, b) => b.line.plant.description.compareTo(a.line.plant.description));
        }
        break;
      case 2:
        if (ascending) {
          widget.devices.sort((a, b) => a.line.name.compareTo(b.line.name));
        } else {
          widget.devices.sort((a, b) => b.line.name.compareTo(a.line.name));
        }
        break;
      case 3:
        if (ascending) {
          widget.devices.sort((a, b) => a.code.compareTo(b.code));
        } else {
          widget.devices.sort((a, b) => b.code.compareTo(a.code));
        }
        break;
      case 4:
        if (ascending) {
          widget.devices.sort((a, b) => a.description.compareTo(b.description));
        } else {
          widget.devices.sort((a, b) => b.description.compareTo(a.description));
        }
        break;
      case 5:
        if (ascending) {
          widget.devices.sort((a, b) => a.id.toString().compareTo(b.id.toString()));
        } else {
          widget.devices.sort((a, b) => b.id.toString().compareTo(a.id.toString()));
        }
        break;
      case 6:
        if (ascending) {
          widget.devices.sort((a, b) => a.useForOEE.toString().compareTo(b.useForOEE.toString()));
        } else {
          widget.devices.sort((a, b) => b.useForOEE.toString().compareTo(a.useForOEE.toString()));
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
          height: widget.devices.length <= 25 ? 156 + widget.devices.length * 56 : 156 + 25 * 56,
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
                        showCheckboxColumn: false,
                        showFirstLastButtons: true,
                        sortAscending: sort,
                        sortColumnIndex: sortingColumnIndex,
                        columnSpacing: 20.0,
                        columns: [
                          DataColumn(
                            label: Text(
                              "Device Type",
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
                              "Plant",
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
                              "Line",
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
                              "Code",
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
                              "Description",
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
                              "Device ID",
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
                              "Used for OEE",
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
                        source: _DataSource(context, widget.devices),
                        rowsPerPage: widget.devices.length > 25 ? 25 : widget.devices.length,
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
  _DataSource(this.context, this._devices) {
    _devices = _devices;
  }

  final BuildContext context;
  List<Device> _devices;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final device = _devices[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            device.deviceType,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            device.line.plant.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            device.line.name,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            device.code,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            device.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            device.id,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          device.useForOEE
              ? Icon(
                  Icons.check,
                  color: isDarkTheme.value ? Colors.green : Colors.black,
                )
              : const Icon(
                  Icons.stop,
                  color: Colors.red,
                ),
        ),
      ],
    );
  }

  @override
  int get rowCount => _devices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
