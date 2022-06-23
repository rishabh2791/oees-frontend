import 'package:flutter/material.dart';
import 'package:oees/domain/entity/user_role.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class UserRoleList extends StatefulWidget {
  final List<UserRole> userRoles;
  const UserRoleList({
    Key? key,
    required this.userRoles,
  }) : super(key: key);

  @override
  State<UserRoleList> createState() => _UserRoleListState();
}

class _UserRoleListState extends State<UserRoleList> {
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
          widget.userRoles.sort((a, b) => a.description.compareTo(b.description));
        } else {
          widget.userRoles.sort((a, b) => b.description.compareTo(a.description));
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
          width: 400,
          height: widget.userRoles.length <= 25 ? 156 + widget.userRoles.length * 56 : 156 + 25 * 56,
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
                              "User Role",
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
                        source: _DataSource(context, widget.userRoles),
                        rowsPerPage: widget.userRoles.length > 25 ? 25 : widget.userRoles.length,
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
  _DataSource(this.context, this._userRoles) {
    _userRoles = _userRoles;
  }

  final BuildContext context;
  List<UserRole> _userRoles;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final plant = _userRoles[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            plant.description,
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
  int get rowCount => _userRoles.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
