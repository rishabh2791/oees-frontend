import 'package:flutter/material.dart';
import 'package:oees/domain/entity/user.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';

class UserList extends StatefulWidget {
  final List<User> users;
  const UserList({
    Key? key,
    required this.users,
  }) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
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
          widget.users.sort((a, b) => a.username.compareTo(b.username));
        } else {
          widget.users.sort((a, b) => b.username.compareTo(a.username));
        }
        break;
      case 1:
        if (ascending) {
          widget.users.sort((a, b) => a.firstName.compareTo(b.firstName));
        } else {
          widget.users.sort((a, b) => b.firstName.compareTo(a.firstName));
        }
        break;
      case 2:
        if (ascending) {
          widget.users.sort((a, b) => a.lastName.compareTo(b.lastName));
        } else {
          widget.users.sort((a, b) => b.lastName.compareTo(a.lastName));
        }
        break;
      case 3:
        if (ascending) {
          widget.users.sort((a, b) =>
              a.userRole.description.compareTo(b.userRole.description));
        } else {
          widget.users.sort((a, b) =>
              b.userRole.description.compareTo(a.userRole.description));
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
          height: widget.users.length <= 25
              ? 156 + widget.users.length * 56
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
                              "Username",
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
                              "First Name",
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
                              "Last Name",
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
                              "User Role",
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
                        source: _DataSource(context, widget.users),
                        rowsPerPage:
                            widget.users.length > 25 ? 25 : widget.users.length,
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
  _DataSource(this.context, this._users) {
    _users = _users;
  }

  final BuildContext context;
  List<User> _users;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    final user = _users[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Text(
            user.username,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            user.firstName,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            user.lastName,
            style: TextStyle(
              fontSize: 16.0,
              color: isDarkTheme.value ? foregroundColor : backgroundColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        DataCell(
          Text(
            user.userRole.description,
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
  int get rowCount => _users.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
