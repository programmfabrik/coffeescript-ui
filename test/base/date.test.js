require('../index');

describe('CUI.DateTime.stringToDateRange', () => {
    test("stringToDateRange :: Empty string", () => {
        const input = "";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: Null", () => {
        const input = null;

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: 1999-12-31", () => {
        const input = "1999-12-31";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(input);
        expect(output.to).toBe(input);
    });

    test("stringToDateRange :: 17.6.1989", () => {
        const input = "17.6.1989";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1989-06-17");
        expect(output.to).toBe("1989-06-17");
    });

    test("stringToDateRange :: INVALID CASE", () => {
        const input = "NOT_VALID";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: 12.3.2010 - 14.3.2010", () => {
        const input = "12.3.2010 - 14.3.2010";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-12");
        expect(output.to).toBe("2010-03-14");
    });

    test("stringToDateRange :: 2010-03-12 - 2010-03-14", () => {
        const input = "2010-03-12 - 2010-03-14";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-12");
        expect(output.to).toBe("2010-03-14");
    });

    test("stringToDateRange :: 1972 - 1974", () => {
        const input = "1972 - 1974";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1972-01-01");
        expect(output.to).toBe("1974-12-31");
    });

    test("stringToDateRange :: 3.2010 - 3.2011", () => {
        const input = "3.2010 - 3.2011";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-01");
        expect(output.to).toBe("2011-03-31");
    });

    test("stringToDateRange :: 3.2010 bis 3.2011", () => {
        const input = "3.2010 bis 3.2011";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-01");
        expect(output.to).toBe("2011-03-31");
    });

    test("stringToDateRange :: 3.2010 to 3.2011", () => {
        const input = "3.2010 to 3.2011";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-01");
        expect(output.to).toBe("2011-03-31");
    });

    test("stringToDateRange :: 2010-03", () => {
        const input = "2010-03";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-01");
        expect(output.to).toBe("2010-03-31");
    });

    test("stringToDateRange :: 11.1777", () => {
        const input = "11.1777";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1777-11-01");
        expect(output.to).toBe("1777-11-30");
    });

    test("stringToDateRange :: 3.2010", () => {
        const input = "3.2010";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-01");
        expect(output.to).toBe("2010-03-31");
    });

    test("stringToDateRange :: 2000", () => {
        const input = "2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2000-01-01");
        expect(output.to).toBe("2000-12-31");
    });

    test("stringToDateRange :: um 2000", () => {
        const input = "um 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500-01-01");
        expect(output.to).toBe("2500-12-31");
    });

    test("stringToDateRange :: um 2000", () => {
        const input = "um 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500-01-01");
        expect(output.to).toBe("2500-12-31");
    });

    test("stringToDateRange :: um 1900", () => {
        const input = "um 1900";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1850-01-01");
        expect(output.to).toBe("1950-12-31");
    });

    test("stringToDateRange :: um 1950", () => {
        const input = "um 1950";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1935-01-01");
        expect(output.to).toBe("1965-12-31");
    });

    test("stringToDateRange :: um 1910", () => {
        const input = "um 1910";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1905-01-01");
        expect(output.to).toBe("1915-12-31");
    });

    test("stringToDateRange :: um 1999", () => {
        const input = "um 1999";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1997-01-01");
        expect(output.to).toBe("2001-12-31");
    });

    test("stringToDateRange :: ca. 1970", () => {
        const input = "ca. 1970";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1965-01-01");
        expect(output.to).toBe("1975-12-31");
    });

    test("stringToDateRange :: vor 2000", () => {
        const input = "vor 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500-01-01");
        expect(output.to).toBe("2000-12-31");
    });

    test("stringToDateRange :: before 2000", () => {
        const input = "before 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500-01-01");
        expect(output.to).toBe("2000-12-31");
    });

    test("stringToDateRange :: vor 1900", () => {
        const input = "vor 1900";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1850-01-01");
        expect(output.to).toBe("1900-12-31");
    });

    test("stringToDateRange :: vor 1950", () => {
        const input = "vor 1950";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1935-01-01");
        expect(output.to).toBe("1950-12-31");
    });

    test("stringToDateRange :: vor 1970", () => {
        const input = "vor 1970";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1965-01-01");
        expect(output.to).toBe("1970-12-31");
    });

    test("stringToDateRange :: vor 1999", () => {
        const input = "vor 1999";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1997-01-01");
        expect(output.to).toBe("1999-12-31");
    });

    test("stringToDateRange :: nach 2000", () => {
        const input = "nach 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2000-01-01");
        expect(output.to).toBe("2500-12-31");
    });

    test("stringToDateRange :: nach 1900", () => {
        const input = "nach 1900";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1900-01-01");
        expect(output.to).toBe("1950-12-31");
    });

    test("stringToDateRange :: nach 1950", () => {
        const input = "nach 1950";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1950-01-01");
        expect(output.to).toBe("1965-12-31");
    });


    test("stringToDateRange :: nach 1910", () => {
        const input = "nach 1910";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1910-01-01");
        expect(output.to).toBe("1915-12-31");
    });

    test("stringToDateRange :: nach 1999", () => {
        const input = "nach 1999";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1999-01-01");
        expect(output.to).toBe("2001-12-31");
    });

    test("stringToDateRange :: 1900 n. Chr.", () => {
        const input = "1900 n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1900-01-01");
        expect(output.to).toBe("1900-12-31");
    });

    test("stringToDateRange :: 1900 v. Chr.", () => {
        const input = "1900 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1900");
        expect(output.to).toBe("-1900");
    });

    test("stringToDateRange :: 1900 BCE", () => {
        const input = "1900 BCE";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1900");
        expect(output.to).toBe("-1900");
    });

    test("stringToDateRange :: 12 Jhd", () => {
        const input = "12 Jhd";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1101-01-01");
        expect(output.to).toBe("1200-12-31");
    });

    test("stringToDateRange :: 12. JHD.", () => {
        const input = "12. JHD.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1101-01-01");
        expect(output.to).toBe("1200-12-31");
    });

    test("stringToDateRange :: 12 Jhd.", () => {
        const input = "12 Jhd.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1101-01-01");
        expect(output.to).toBe("1200-12-31");
    });

    test("stringToDateRange :: 20th century", () => {
        const input = "20th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1901-01-01");
        expect(output.to).toBe("2000-12-31");
    });

    test("stringToDateRange :: Anfang 16. Jh.", () => {
        const input = "Anfang 16. Jh.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1501-01-01");
        expect(output.to).toBe("1516-12-31");
    });

    test("stringToDateRange :: Anfang 16. Jh. v. Chr.", () => {
        const input = "Anfang 16. Jh. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1600");
        expect(output.to).toBe("-1585");
    });

    test("stringToDateRange :: Early 16th century", () => {
        const input = "Early 16th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1501-01-01");
        expect(output.to).toBe("1516-12-31");
    });

    test("stringToDateRange :: Early 16th century BC", () => {
        const input = "Early 16th century BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1600");
        expect(output.to).toBe("-1585");
    });

    test("stringToDateRange :: Ende 13. Jh.", () => {
        const input = "Ende 13. Jh.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1285-01-01");
        expect(output.to).toBe("1300-12-31");
    });

    test("stringToDateRange :: Ende 13. Jh. v. Chr.", () => {
        const input = "Ende 13. Jh. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1216");
        expect(output.to).toBe("-1201");
    });

    test("stringToDateRange :: Late 13th century", () => {
        const input = "Late 13th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1285-01-01");
        expect(output.to).toBe("1300-12-31");
    });

    test("stringToDateRange :: Late 13th century BC", () => {
        const input = "Late 13th century BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1216");
        expect(output.to).toBe("-1201");
    });

    test("stringToDateRange :: 3. Jt. bc", () => {
        const input = "3. Jt. bc";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-2999");
        expect(output.to).toBe("-2000");
    });

    test("stringToDateRange :: vor 4000 bc", () => {
        const input = "vor 4000 bc";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-4500");
        expect(output.to).toBe("-4000");
    });

    test("stringToDateRange :: ca. 3000 bc", () => {
        const input = "ca. 3000 bc";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-3500");
        expect(output.to).toBe("-2500");
    });

    test("stringToDateRange :: nach 1000 bc", () => {
        const input = "nach 1000 bc";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1000");
        expect(output.to).toBe("-0500");
    });

    test("stringToDateRange :: vor 600 v. Chr.", () => {
        const input = "vor 600 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0650");
        expect(output.to).toBe("-0600");
    });

    test("stringToDateRange :: ca. 3000 v. Chr.", () => {
        const input = "ca. 3000 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-3500");
        expect(output.to).toBe("-2500");
    });

    test("stringToDateRange :: nach 1000 v. Chr.", () => {
        const input = "nach 1000 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1000");
        expect(output.to).toBe("-0500");
    });

    test("stringToDateRange :: nach -1000", () => {
        const input = "nach -1000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1000");
        expect(output.to).toBe("-0500");
    });

    test("stringToDateRange :: bis 1786", () => {
        const input = "bis 1786";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1784-01-01");
        expect(output.to).toBe("1786-12-31");
    });

    test("stringToDateRange :: -244 - 249 n. Chr.", () => {
        const input = "-244 - 249 n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0244");
        expect(output.to).toBe("0249");
    });

    test("stringToDateRange :: -244 bis 249", () => {
        const input = "-244 bis 249";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0244");
        expect(output.to).toBe("0249");
    });

    test("stringToDateRange :: -249 bis -244", () => {
        const input = "-249 bis -244";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0249");
        expect(output.to).toBe("-0244");
    });

    test("stringToDateRange :: von -244 bis 249", () => {
        const input = "von -244 bis 249";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0244");
        expect(output.to).toBe("0249");
    });

    test("stringToDateRange :: zwischen -244 bis 249", () => {
        const input = "zwischen -244 bis 249";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0244");
        expect(output.to).toBe("0249");
    });


    test("stringToDateRange :: -250 bis -200", () => {
        const input = "-250 bis -200";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0250");
        expect(output.to).toBe("-0200");
    });

    test("stringToDateRange :: -1500 bis -1000", () => {
        const input = "-1500 bis -1000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1500");
        expect(output.to).toBe("-1000");
    });

    test("stringToDateRange :: zwischen -244 und 249", () => {
        const input = "zwischen -244 und 249";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0244");
        expect(output.to).toBe("0249");
    });

    test("stringToDateRange :: zwischen 2010 und 2015", () => {
        const input = "zwischen 2010 und 2015";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-01-01");
        expect(output.to).toBe("2015-12-31");
    });

    test("stringToDateRange :: 1001 bis 1500", () => {
        const input = "1001 bis 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001-01-01");
        expect(output.to).toBe("1500-12-31");
    });

    test("stringToDateRange :: 1000 bis 1500", () => {
        const input = "1000 bis 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1000");
        expect(output.to).toBe("1500-12-31");
    });

    test("stringToDateRange :: 200 bis 250", () => {
        const input = "200 bis 250";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0200");
        expect(output.to).toBe("0250");
    });

    test("stringToDateRange :: -244-249", () => {
        const input = "-244-249";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: 244-249", () => {
        const input = "244-249";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: vor 1500", () => {
        const input = "vor 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1450-01-01");
        expect(output.to).toBe("1500-12-31");
    });

    test("stringToDateRange :: vor 150", () => {
        const input = "vor 150";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0135");
        expect(output.to).toBe("0150");
    });

    test("stringToDateRange :: vor 15", () => {
        const input = "vor 15";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0013");
        expect(output.to).toBe("0015");
    });

    test("stringToDateRange :: nach 1500", () => {
        const input = "nach 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500-01-01");
        expect(output.to).toBe("1550-12-31");
    });

    test("stringToDateRange :: nach 150", () => {
        const input = "nach 150";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0150");
        expect(output.to).toBe("0165");
    });

    test("stringToDateRange :: nach 15", () => {
        const input = "nach 15";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0015");
        expect(output.to).toBe("0017");
    });

    test("stringToDateRange :: um 1500", () => {
        const input = "um 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1450-01-01");
        expect(output.to).toBe("1550-12-31");
    });

    test("stringToDateRange :: um 150", () => {
        const input = "um 150";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0135");
        expect(output.to).toBe("0165");
    });

    test("stringToDateRange :: um 15", () => {
        const input = "um 15";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0013");
        expect(output.to).toBe("0017");
    });

    test("stringToDateRange :: 3. Jt. v. Chr.", () => {
        const input = "3. Jt. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-2999");
        expect(output.to).toBe("-2000");
    });

    test("stringToDateRange :: 3. Jt. n. Chr.", () => {
        const input = "3. Jt. n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: 10.04.2010", () => {
        const input = "10.04.2010";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-04-10");
        expect(output.to).toBe("2010-04-10");
    });

    test("stringToDateRange :: 250 v. Chr. - 250 n. Chr.", () => {
        const input = "250 v. Chr. - 250 n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0250");
        expect(output.to).toBe("0250");
    });

    test("stringToDateRange :: 2000 BC", () => {
        const input = "2000 BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-2000");
        expect(output.to).toBe("-2000");
    });

    test("stringToDateRange :: 2000 AD", () => {
        const input = "2000 AD";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2000-01-01");
        expect(output.to).toBe("2000-12-31");
    });

    test("stringToDateRange :: 5. Jhd. nach Chr.", () => {
        const input = "5. Jhd. nach Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0401");
        expect(output.to).toBe("0500");
    });

    test("stringToDateRange :: 5. Jhd. n. Chr.", () => {
        const input = "5. Jhd. n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0401");
        expect(output.to).toBe("0500");
    });

    test("stringToDateRange :: 5. Jhd. nach Chr", () => {
        const input = "5. Jhd. nach Chr";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0401");
        expect(output.to).toBe("0500");
    });

    test("stringToDateRange :: 5. Jhd. vor Chr", () => {
        const input = "5. Jhd. vor Chr";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0500");
        expect(output.to).toBe("-0401");
    });

    test("stringToDateRange :: 5. Jhd. vor Chr.", () => {
        const input = "5. Jhd. vor Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0500");
        expect(output.to).toBe("-0401");
    });

    test("stringToDateRange :: 5. Jhd. v. Chr.", () => {
        const input = "5. Jhd. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0500");
        expect(output.to).toBe("-0401");
    });

    test("stringToDateRange :: 554 v. Chr. - 62 n. Chr.", () => {
        const input = "554 v. Chr. - 62 n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0554");
        expect(output.to).toBe("0062");
    });

    test("stringToDateRange :: 311 - 289 BC", () => {
        const input = "311 - 289 BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0311");
        expect(output.to).toBe("-0289");
    });

    test("stringToDateRange :: 311 - 289 v. Chr.", () => {
        const input = "311 - 289 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0311");
        expect(output.to).toBe("-0289");
    });

    test("stringToDateRange :: 311 - 289 B.C.", () => {
        const input = "311 - 289 B.C.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0311");
        expect(output.to).toBe("-0289");
    });

    test("stringToDateRange :: 543 BC - 876 nach Chr.", () => {
        const input = "543 BC - 876 nach Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0543");
        expect(output.to).toBe("0876");
    });

    test("stringToDateRange :: 123 BC - 678 CE", () => {
        const input = "123 BC - 678 CE";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0123");
        expect(output.to).toBe("0678");
    });

    test("stringToDateRange :: 800 bc - 900 ad", () => {
        const input = "800 bc - 900 ad";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0800");
        expect(output.to).toBe("0900");
    });

    test("stringToDateRange :: 800 ac - 900 ad", () => {
        const input = "800 ac - 900 ad";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0800");
        expect(output.to).toBe("0900");
    });

    test("stringToDateRange :: 12 Jhd ac", () => {
        const input = "12 Jhd ac";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1200");
        expect(output.to).toBe("-1101");
    });

    test("stringToDateRange :: 198 - 211 n. Chr.", () => {
        const input = "198 - 211 n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0198");
        expect(output.to).toBe("0211");
    });

    test("stringToDateRange :: ab 300 ad", () => {
        const input = "ab 300 ad";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0300");
        expect(output.to).toBe("0350");
    });
});

describe('CUI.DateTime.dateRangeToString', () => {
    beforeEach(() => {
        CUI.DateTime.setLocale("de-DE")
    });

    test("dateRangeToString :: Invalid case", () => {
        const from = null
        const to = "2000-01-01"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBeUndefined()
    });

    test("dateRangeToString :: 2000-01-01 - 2000-01-01", () => {
        const from = "2000-01-01"
        const to = "2000-01-01"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2000-01-01")
    });

    test("dateRangeToString :: 2000-01-01 - 2500-12-20", () => {
        const from = "2000-01-01"
        const to = "2500-12-20"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2000-01-01 bis 2500-12-20")
    });

    test("dateRangeToString :: 2000-01-01 - 2500-12-31", () => {
        const from = "2000-01-01"
        const to = "2500-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 2000")
    });

    test("dateRangeToString :: 2000 - 2500", () => {
        const from = "2000"
        const to = "2500"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Datum ungültig")
    });

    test("dateRangeToString :: 1900-01-01 - 1950-12-31", () => {
        const from = "1900-01-01"
        const to = "1950-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1900")
    });

    test("dateRangeToString :: 1950-01-01 - 1965-12-31", () => {
        const from = "1950-01-01"
        const to = "1965-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1950")
    });

    test("dateRangeToString :: 1910-01-01 - 1915-12-31", () => {
        const from = "1910-01-01"
        const to = "1915-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1910")
    });

    test("dateRangeToString :: 1999-01-01 - 2001-12-31", () => {
        const from = "1999-01-01"
        const to = "2001-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1999")
    });

    test("dateRangeToString :: -1000 - -0500", () => {
        const from = "-1000"
        const to = "-0500"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1000 v. Chr.")
    });

    test("dateRangeToString :: 1500-01-01 - 2000-12-31", () => {
        const from = "1500-01-01"
        const to = "2000-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 2000")
    });

    test("dateRangeToString :: 1850-01-01 - 1900-12-31", () => {
        const from = "1850-01-01"
        const to = "1900-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 1900")
    });

    test("dateRangeToString :: 1935-01-01 - 1950-12-31", () => {
        const from = "1850-01-01"
        const to = "1900-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 1900")
    });

    test("dateRangeToString :: 1965-01-01 - 1970-12-31", () => {
        const from = "1965-01-01"
        const to = "1970-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 1970")
    });

    test("dateRangeToString :: -0665 - -0660", () => {
        const from = "-0665"
        const to = "-0660"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 660 v. Chr.")
    });

    test("dateRangeToString :: 1500-01-01 - 2500-12-31", () => {
        const from = "1500-01-01"
        const to = "2500-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 2000")
    });

    test("dateRangeToString :: 1935-01-01 - 1965-12-31", () => {
        const from = "1935-01-01"
        const to = "1965-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 1950")
    });

    test("dateRangeToString :: 1935-01-01 - 1965-12-31", () => {
        const from = "1905-01-01"
        const to = "1915-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 1910")
    });

    test("dateRangeToString :: 1997-01-01 - 2001-12-31", () => {
        const from = "1997-01-01"
        const to = "2001-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 1999")
    });

    test("dateRangeToString :: -1950 - -1850", () => {
        const from = "-1950"
        const to = "-1850"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 1900 v. Chr.")
    });

    test("dateRangeToString :: -2999 - -2000", () => {
        const from = "-2999"
        const to = "-2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("3. Jt. v. Chr.")
    });

    test("dateRangeToString :: -0999 - 0000", () => {
        const from = "-0999"
        const to = "0000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1. Jt. v. Chr.")
    });

    test("dateRangeToString :: -0500 - -0401", () => {
        const from = "-0500"
        const to = "-0401"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("5. Jhd. v. Chr.")
    });

    test("dateRangeToString :: -0505 - -0406", () => {
        const from = "-0505"
        const to = "-0406"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("-0505 bis -0406")
    });

    test("dateRangeToString :: 0401 - 0500", () => {
        const from = "0401"
        const to = "0500"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("5. Jhd.")
    });

    test("dateRangeToString :: -1600 - -1585", () => {
        const from = "-1600"
        const to = "-1585"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Anfang 16. Jh. v. Chr.")
    });

    test("dateRangeToString :: 1501-01-01 - 1516-12-31", () => {
        const from = "1501-01-01"
        const to = "1516-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Anfang 16. Jh.")
    });

    test("dateRangeToString :: 1501-01-01 - 1516-12-31", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1501-01-01"
        const to = "1516-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Early 16th century")
    });

    test("dateRangeToString :: -1216 - -1201", () => {
        const from = "-1216"
        const to = "-1201"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Ende 13. Jh. v. Chr.")
    });

    test("dateRangeToString :: 1285-01-01 - 1300-12-31", () => {
        const from = "1285-01-01"
        const to = "1300-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Ende 13. Jh.")
    });

    test("dateRangeToString :: 1285-01-01 - 1285-12-31", () => {
        const from = "1285-01-01"
        const to = "1285-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1285")
    });

    test("dateRangeToString :: 1285-01-01 - 1285-05-31", () => {
        const from = "1285-01-01"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1285-01-01 bis 1285-05-31")
    });

    test("dateRangeToString :: 1285-01-01 - 1285-05-31", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1285-01-01"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1285-01-01 to 1285-05-31")
    });

    test("dateRangeToString :: Invalid date", () => {
        const from = "2222-22-22"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Datum ungültig")
    });

    test("dateRangeToString :: Invalid date", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "2222-22-22"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Invalid Date")
    });

    test("dateRangeToString :: 1285-01-01 - 1285-01-31", () => {
        const from = "1285-01-01"
        const to = "1285-01-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("01.1285")
    });

    test("dateRangeToString :: 1285-01-01 - 1285-01-31", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1285-01-01"
        const to = "1285-01-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("01/1285")
    });

    test("dateRangeToString :: 1901-01-01 - 2000-12-31", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1901-01-01"
        const to = "2000-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("20th century")
    });
});