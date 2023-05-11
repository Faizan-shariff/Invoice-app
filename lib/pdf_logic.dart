import 'dart:ffi';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'mobile.dart';

class PDFLogic {
  const PDFLogic({
    required this.todayDate,
    required this.customerName,
    required this.itemNames,
    required this.fees,
    required this.totalExpected,
    //required this.totalPaid,
    //required this.outstanding,
  });

  final String customerName;
  final String todayDate;
  final int totalExpected;
  //final String totalPaid;
  //final int outstanding;
  final List itemNames;
  final List fees;

  Future<Uint8List> _readImageData(String fullImagePath) async {
    final data = await rootBundle.load(fullImagePath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> generateInvoice() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    PdfPageTemplateElement footer = PdfPageTemplateElement(
        Rect.fromLTWH(0, 0, document.pageSettings.size.width, 50));

    //Create the page number field
    PdfPageNumberField pageNumber = PdfPageNumberField(
        font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)));

//Sets the number style for page number
    pageNumber.numberStyle = PdfNumberStyle.upperRoman;

//Create the page count field
    PdfPageCountField count = PdfPageCountField(
        font: PdfStandardFont(PdfFontFamily.timesRoman, 14),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)));

//set the number style for page count
    count.numberStyle = PdfNumberStyle.upperRoman;


//Create the composite field with page number page count
    PdfCompositeField compositeField = PdfCompositeField(
        font: PdfStandardFont(PdfFontFamily.helvetica, 15),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        text: 'Signature',
        fields: <PdfAutomaticField>[pageNumber, count]);
    compositeField.bounds = footer.bounds;

//Add the composite field in footer
    compositeField.draw(footer.graphics,
        Offset(425, 50 - PdfStandardFont(PdfFontFamily.helvetica, 16).height));

//Add the footer at the bottom of the document
    document.template.bottom = footer;



    // logo
    page.graphics.drawImage(
        PdfBitmap(await _readImageData('assets/images/logo.png')),
        const Rect.fromLTWH(0, 0, 220,150));
    // end of logo

    // Receipt text
    page.graphics.drawString('Invoice',
        PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
        bounds: const Rect.fromLTRB(440, 0, 0, 0));
    // end of Receipt text

    // Date Issued text
    page.graphics.drawString(
        todayDate, PdfStandardFont(PdfFontFamily.helvetica, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: const Rect.fromLTRB(515, 25, 0, 0));
    // end of Date Issued text

    //Address
    page.graphics.drawString('\n#4/1, Shankarnag Road,'
        '\n Opp.State Bank Of India, Gottigere'
        '\nBannerghatta Road,Bengaluru-560083'
        '\n Mob: 9845316544',
        PdfStandardFont(PdfFontFamily.helvetica, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: const Rect.fromLTRB(515,50 , 0, 0));
    // end o Address


    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 15,
          style: PdfFontStyle.bold),
      cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
    );

    PdfGrid grid1 = PdfGrid();
    grid1.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 15,
      style: PdfFontStyle.bold),
      cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
    );

    grid1.columns.add(count: 3);
    grid1.headers.add(1);

    grid.columns.add(count: 2);
    grid.headers.add(1);

    // header text
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = " Name/Vehicle No. ";
    header.cells[1].value = " "+customerName;
    PdfGridRow row1;
    row1=grid.rows.add();
    row1.cells[0].value = " Date ";
    row1.cells[1].value = " "+todayDate;
    // end of header text

    // header text
    PdfGridRow header1 = grid1.headers[0];
    header1.cells[0].value =" SL No.";
    header1.cells[1].value = " Description ";
    header1.cells[2].value = " Amount ";

    grid1.columns[0].width=80;
    grid1.columns[2].width=150;

    // end of header text

    // Rows for item names and fees
    PdfGridRow row;
    int serialno =0;
    for (var i = 0; i < itemNames.length; i++) {
      row = grid1.rows.add();
      row.cells[0].value = " "+ (++serialno).toString();
      row.cells[1].value = " "+itemNames[i];
      row.cells[2].value = ' Rs. ' + fees[i].toString();
    }
    // end of rows for item names and fees

    // Row for total fees expected
    row = grid1.rows.add();
    row.cells[0].value = '\t \t \t \t \t \t \t \t  \t  Grand Total';
    row.cells[1].value = ' ';
    row.cells[2].value = ' Rs. $totalExpected';
    // end of row for total fees expected
    row.cells[0].columnSpan = 2;

    // Row for amount paid
    // row = grid.rows.add();
    // row.cells[0].value = ' Amount Paid ';
    // row.cells[1].value = ' Rs. $totalPaid';
    // end of row for amount paid

    // ROW 4 (Outstanding currently)
    // row = grid.rows.add();
    // row.cells[0].value = ' Balance ';
    // row.cells[1].value = ' Rs. $outstanding';
    PdfStringFormat format = PdfStringFormat();
    format.alignment = PdfTextAlignment.center;
    format.lineAlignment = PdfVerticalAlignment.bottom;

    grid.columns[0].format = format;
    grid.columns[1].format = format;
    grid1.columns[0].format = format;
    grid1.columns[1].format = format;
    grid1.columns[2].format = format;
    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 170, 0, 0));
    grid1.draw(page: page, bounds: const Rect.fromLTWH(0, 250, 0, 0),format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate));

    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, '$customerName.pdf');
  }
}
