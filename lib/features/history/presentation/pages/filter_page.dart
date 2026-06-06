import 'package:flutter/material.dart';
import 'package:flutter_demo/components/button3.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({
    required this.onApply,
    required this.onReset,
    this.startDate,
    this.endDate,
    Key? key,
  }) : super(key: key);

  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime start, DateTime end) onApply;
  final Function() onReset;

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late DateRangePickerController _datePickerController;
  PickerDateRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = PickerDateRange(widget.startDate, widget.endDate);
    _datePickerController = DateRangePickerController();
    _datePickerController.selectedRange = _selectedRange;
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select date'),
        backgroundColor: Theme.of(context).colorScheme.colorBar,
        titleSpacing: 0,
        leading: RoundButton(
            padding: const EdgeInsets.only(left: 10),
            color: Colors.transparent,
            iconColor: Theme.of(context).colorScheme.menuFontColor1,
            iconData: Icons.arrow_back_ios,
            size: 50,
            iconSize: 22,
            onPressed: (v) async {
              Navigator.pop(context);
            }),
        actions: [
          if (_selectedRange?.startDate != null)
            Padding(
                padding: EdgeInsets.only(right: 8),
                child: Button3(
                    text: 'Reset',
                    color: Theme.of(context).colorScheme.buttonOption,
                    colorText: Theme.of(context).colorScheme.buttonOptionText,
                    onPressed: () {
                      setState(() {
                        _selectedRange = null;
                        _datePickerController.selectedRange = null;
                      });
                      widget.onReset();
                    })),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SfDateRangePicker(
                controller: _datePickerController,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  setState(() {
                    if (args.value is PickerDateRange) {
                      _selectedRange = args.value;
                    }
                  });
                },
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedRange: _selectedRange,
              ),
            ),
            SafeArea(
              child: Container(
                width: double.infinity,
                height: 40,
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Button3(
                    text: 'Apply',
                    color: Theme.of(context).colorScheme.buttonOption,
                    colorText: Theme.of(context).colorScheme.buttonOptionText,
                    onPressed: _selectedRange?.startDate == null
                        ? null
                        : () {
                            final startDate = _selectedRange?.startDate;
                            final endDate =
                                _selectedRange?.endDate ?? DateTime.now();
                            if (startDate != null)
                              widget.onApply(
                                startDate,
                                endDate,
                              );
                            Navigator.pop(context, _selectedRange);
                          }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
