import 'package:flutter/material.dart';
import 'package:oees/domain/entity/sku_speed.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class SKUSpeedList extends StatefulWidget {
  final List<SKUSpeed> skuSpeeds;
  const SKUSpeedList({
    Key? key,
    required this.skuSpeeds,
  }) : super(key: key);

  @override
  State<SKUSpeedList> createState() => _SKUSpeedListState();
}

class _SKUSpeedListState extends State<SKUSpeedList> {
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
          widget.skuSpeeds.sort((a, b) => a.sku.plant.description.compareTo(b.sku.plant.description));
        } else {
          widget.skuSpeeds.sort((a, b) => b.sku.plant.description.compareTo(a.sku.plant.description));
        }
        break;
      case 1:
        if (ascending) {
          widget.skuSpeeds.sort((a, b) => a.sku.code.compareTo(b.sku.code));
        } else {
          widget.skuSpeeds.sort((a, b) => b.sku.code.compareTo(a.sku.code));
        }
        break;
      case 2:
        if (ascending) {
          widget.skuSpeeds.sort((a, b) => a.sku.description.compareTo(b.sku.description));
        } else {
          widget.skuSpeeds.sort((a, b) => b.sku.description.compareTo(a.sku.description));
        }
        break;
      case 3:
        if (ascending) {
          widget.skuSpeeds.sort((a, b) => a.speed.compareTo(b.speed));
        } else {
          widget.skuSpeeds.sort((a, b) => b.speed.compareTo(a.speed));
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
          height: widget.skuSpeeds.length <= 25 ? 156 + widget.skuSpeeds.length * 56 : 156 + 25 * 56,
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
                              "Material Code",
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
                              "Material Description",
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
                              "Speed",
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
                        source: _DataSource(context, widget.skuSpeeds),
                        rowsPerPage: widget.skuSpeeds.length > 25 ? 25 : widget.skuSpeeds.length,
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
  _DataSource(this.context, this._skuSpeeds) {
    _skuSpeeds = _skuSpeeds;
  }

  final BuildContext context;
  List<SKUSpeed> _skuSpeeds;
  TextEditingController ipAddressController = TextEditingController();

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final skuSpeed = _skuSpeeds[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            skuSpeed.sku.plant.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            skuSpeed.sku.code,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            skuSpeed.sku.description,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            skuSpeed.speed.toString(),
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
  int get rowCount => _skuSpeeds.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
