part of csv_to_list_test;

main_transformer() {

  test('Works as transformer (simple test)', () {
    var stream = new Stream.fromIterable([csvSimpleStringsSingleRowComma]);
    var f_rows = stream.transform(commaDoubleQuotCsvToListConverter).toList();
    expect(f_rows, completion([simpleStringsSingleRow]));
  });

  test('Works as transformer (complex multicharacter delimiters)', () {
    var csvStream = new Stream.fromIterable(csvComplex_parts);
    var f_rows = csvStream.transform(complexConverter).toList();
    expect(f_rows, completion(complexRows));
  });

  test('Works as transformer '
       '(complex multicharacter delimiters, difficult line endings)', () {
    var csvStream = new Stream.fromIterable(csvComplex_parts_ending1);
    var f_rows = csvStream.transform(complexConverter).toList();
    expect(f_rows, completion(complexRows_ending1));

    var csvStream2 = new Stream.fromIterable(csvComplex_parts_ending2);
    var f_rows2 = csvStream2.transform(complexConverter).toList();
    expect(f_rows2, completion(complexRows_ending2));
  });

  test('Works as transformer '
       '(complex multicharacter delimiters, repeating patterns)', () {
    var csvStream = new Stream.fromIterable(csvComplex2_parts);
    var f_rows = csvStream.transform(complex2Converter).toList();
    expect(f_rows, completion(complexRows2));
  });

  test('Works as transformer '
       '(complex multicharacter delimiters, "embedded" patterns)', () {
    var csvStream = new Stream.fromIterable(csvComplex3_parts);
    var f_rows = csvStream.transform(complex3Converter).toList();
    expect(f_rows, completion(complexRows3));
  });

  test('Transformer throws an exception if not allowInvalid and csv ends '
       'without text end delimiter', () {
    const List<String> csv = const ['abc,"d','ef,xyz'];
    final csvStream = new Stream.fromIterable(csv);
    final converter = new CsvToListConverter(allowInvalid: false);

    var fun = () => csvStream.transform(converter).toList();

    expect(fun(), throwsFormatException);
  });

  test('Transformer throws an exception if not allowInvalid and eol is null',
       () {
    var csvStream = new Stream.fromIterable(csvComplex3_parts);
    final converter = new CsvToListConverter(eol: null, allowInvalid: false);

    var fun = () => csvStream.transform(converter).toList();
    expect(fun(), throwsArgumentError);
  });

  test('Autodetecting settings works in transformer mode', () {
    var det = new FirstOccurenceSettingsDetector(fieldDelimiters: [',', ';'],
                                                 textDelimiters: ['"', "'"],
                                                 textEndDelimiters: ['"', "'"],
                                                 eols: ['\r\n', '\n']);
    var converter = new CsvToListConverter(csvSettingsDetector: det,
                                           parseNumbers: true);
    var stream = new Stream.fromIterable([csvSimpleStringsSingleRowComma]);
    var f_rows = stream.transform(converter).toList();
    expect(f_rows, completion([simpleStringsSingleRow]));

    det = new FirstOccurenceSettingsDetector(fieldDelimiters: [',', 'b'],
                                             textDelimiters: ["'", '"'],
                                             textEndDelimiters: ['.', '"'],
                                             eols: ['\n']);
    converter = new CsvToListConverter(csvSettingsDetector: det,
                                       parseNumbers: false);
    stream = new Stream.fromIterable([csvSingleRowComma]);
    f_rows = stream.transform(converter).toList();
    expect(f_rows, completion([singleRowAllText]));


    det = new FirstOccurenceSettingsDetector(fieldDelimiters: ['aa', '2'],
                                             textDelimiters: ['bb', '"'],
                                             textEndDelimiters: ['"', 'bb']);
    converter = new CsvToListConverter(csvSettingsDetector: det,
                                       parseNumbers: true);
    stream = new Stream.fromIterable([csvSingleRowAaBb]);
    f_rows = stream.transform(converter).toList();
    expect(f_rows, completion([singleRow]));
  });


  test('Transformer autodetects settings for a multiline csv correctly', () {
    var det = new FirstOccurenceSettingsDetector(eols: ['\r\n', '\n']);
    var converter = new CsvToListConverter(csvSettingsDetector: det);
    var eol = '\n';
    var csvStream = new Stream.fromIterable([csvSingleRowComma,
                                             eol,
                                             csvSingleRowComma,
                                             eol,
                                             csvSingleRowComma]);
    var f_rows = csvStream.transform(converter).toList();
    expect(f_rows, completion(multipleRows));

    det = new FirstOccurenceSettingsDetector(eols: ['\r\n', '\n'],
                                             textDelimiters: ['""', "'"],
                                             textEndDelimiters: ['««', '!']);
    converter = new CsvToListConverter(csvSettingsDetector: det);
    csvStream = new Stream.fromIterable(autodetectCsv_parts);
    f_rows = csvStream.transform(converter).toList();
    expect(f_rows, completion(autodetectRows));
  });

}