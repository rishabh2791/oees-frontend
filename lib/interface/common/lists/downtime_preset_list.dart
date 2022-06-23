import 'package:flutter/material.dart';
import 'package:oees/domain/entity/downtime_Preset.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class DowntimePresetList extends StatefulWidget {
  final List<DowntimePreset> presets;
  const DowntimePresetList({
    Key? key,
    required this.presets,
  }) : super(key: key);

  @override
  State<DowntimePresetList> createState() => _DowntimePresetListState();
}

class _DowntimePresetListState extends State<DowntimePresetList> {
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
          widget.presets.sort((a, b) => a.type.compareTo(b.type));
        } else {
          widget.presets.sort((a, b) => b.type.compareTo(a.type));
        }
        break;
      case 1:
        if (ascending) {
          widget.presets.sort((a, b) => a.description.compareTo(b.description));
        } else {
          widget.presets.sort((a, b) => b.description.compareTo(a.description));
        }
        break;
      case 2:
        if (ascending) {
          widget.presets.sort((a, b) => a.defaultPeriod.compareTo(b.defaultPeriod));
        } else {
          widget.presets.sort((a, b) => b.defaultPeriod.compareTo(a.defaultPeriod));
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
          height: widget.presets.length <= 25 ? 156 + widget.presets.length * 56 : 156 + 25 * 56,
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
                        ],
                        source: _DataSource(context, widget.presets),
                        rowsPerPage: widget.presets.length > 25 ? 25 : widget.presets.length,
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
  _DataSource(this.context, this._presets) {
    _presets = _presets;
  }

  final BuildContext context;
  List<DowntimePreset> _presets;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final preset = _presets[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            preset.type,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            preset.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            preset.defaultPeriod.toString(),
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
  int get rowCount => _presets.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
