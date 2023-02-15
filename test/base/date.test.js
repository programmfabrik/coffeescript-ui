require('../index');

describe('CUI.DateTime.stringToDateRange', () => {
    test("stringToDateRange :: Empty string", () => {
        const input = "";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: null", () => {
        const input = null;

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.error).toBeDefined()
    });

    test("stringToDateRange :: 1999", () => {
        const input = "1999";

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

    test("stringToDateRange :: 12.3.2010 – 14.3.2010", () => {
        const input = "12.3.2010 – 14.3.2010";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-12");
        expect(output.to).toBe("2010-03-14");
    });

    test("stringToDateRange :: 12.3.2010 — 14.3.2010", () => {
        const input = "12.3.2010 — 14.3.2010";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2010-03-12");
        expect(output.to).toBe("2010-03-14");
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

        expect(output.from).toBe("1972");
        expect(output.to).toBe("1974");
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

        expect(output.from).toBe("2000");
        expect(output.to).toBe("2000");
    });

    test("stringToDateRange :: um 2000", () => {
        const input = "um 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500");
        expect(output.to).toBe("2500");
    });

    test("stringToDateRange :: um 2000", () => {
        const input = "um 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500");
        expect(output.to).toBe("2500");
    });

    test("stringToDateRange :: um 1900", () => {
        const input = "um 1900";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1850");
        expect(output.to).toBe("1950");
    });

    test("stringToDateRange :: um 1950", () => {
        const input = "um 1950";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1935");
        expect(output.to).toBe("1965");
    });

    test("stringToDateRange :: um 1910", () => {
        const input = "um 1910";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1905");
        expect(output.to).toBe("1915");
    });

    test("stringToDateRange :: um 1999", () => {
        const input = "um 1999";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1997");
        expect(output.to).toBe("2001");
    });

    test("stringToDateRange :: ca. 1970", () => {
        const input = "ca. 1970";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1965");
        expect(output.to).toBe("1975");
    });

    test("stringToDateRange :: vor 2000", () => {
        const input = "vor 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("2000");
    });

    test("stringToDateRange :: vor 1900", () => {
        const input = "vor 1900";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("1900");
    });

    test("stringToDateRange :: vor 1950", () => {
        const input = "vor 1950";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("1950");
    });

    test("stringToDateRange :: vor 1970", () => {
        const input = "vor 1970";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("1970");
    });

    test("stringToDateRange :: vor 1999", () => {
        const input = "vor 1999";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("1999");
    });

    test("stringToDateRange :: nach 2000", () => {
        const input = "nach 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2000");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: after 2000", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "after 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2000");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: before 2000", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "before 2000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.to).toBe("2000");
        expect(output.from).toBe(undefined);
    });

    test("stringToDateRange :: after 2000 BC", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "after 2000 BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-2000");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: before 2000 BC", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "before 2000 BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.to).toBe("-2000");
        expect(output.from).toBe(undefined);
    });

    test("stringToDateRange :: nach 1900", () => {
        const input = "nach 1900";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1900");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: nach 1950", () => {
        const input = "nach 1950";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1950");
        expect(output.to).toBe(undefined);
    });


    test("stringToDateRange :: nach 1910", () => {
        const input = "nach 1910";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1910");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: nach 1999", () => {
        const input = "nach 1999";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1999");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: 1900 n. Chr.", () => {
        const input = "1900 n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1900");
        expect(output.to).toBe("1900");
    });

    test("stringToDateRange :: 1900 v. Chr.", () => {
        const input = "1900 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1899");
        expect(output.to).toBe("-1899");
    });

    test("stringToDateRange :: 1900 BCE", () => {
        const input = "1900 BCE";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1899");
        expect(output.to).toBe("-1899");
    });

    test("stringToDateRange :: 12 Jhd", () => {
        const input = "12 Jhd";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1101");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 12. JHD.", () => {
        const input = "12. JHD.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1101");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 12 Jhd.", () => {
        const input = "12 Jhd.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1101");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 20th century", () => {
        const input = "20th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1901");
        expect(output.to).toBe("2000");
    });

    test("stringToDateRange :: Anfang 16. Jh.", () => {
        const input = "Anfang 16. Jh.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1501");
        expect(output.to).toBe("1516");
    });

    test("stringToDateRange :: Anfang 16. Jh. v. Chr.", () => {
        const input = "Anfang 16. Jh. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1599");
        expect(output.to).toBe("-1584");
    });

    test("stringToDateRange :: Early 16th century", () => {
        const input = "Early 16th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1501");
        expect(output.to).toBe("1516");
    });

    test("stringToDateRange :: 10th century", () => {
        const input = "10th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0901");
        expect(output.to).toBe("1000");
    });

    test("stringToDateRange :: 10th century BC", () => {
        const input = "10th century BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0999");
        expect(output.to).toBe("-0900");
    });

    test("stringToDateRange :: Early 16th century BC", () => {
        const input = "Early 16th century BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1599");
        expect(output.to).toBe("-1584");
    });

    test("stringToDateRange :: Ende 13. Jh.", () => {
        const input = "Ende 13. Jh.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1285");
        expect(output.to).toBe("1300");
    });

    test("stringToDateRange :: Ende 13. Jh. v. Chr.", () => {
        const input = "Ende 13. Jh. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1214");
        expect(output.to).toBe("-1199");
    });

    test("stringToDateRange :: Late 13th century", () => {
        const input = "Late 13th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1285");
        expect(output.to).toBe("1300");
    });

    test("stringToDateRange :: Late 13th century BC", () => {
        const input = "Late 13th century BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1214");
        expect(output.to).toBe("-1199");
    });

    test("stringToDateRange :: 13. Jh. v. Chr.", () => {
        const input = "13. Jh. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1299");
        expect(output.to).toBe("-1200");
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

        expect(output.from).toBe(undefined);
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
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: vor 600 v. Chr.", () => {
        const input = "vor 600 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
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
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: nach -1000", () => {
        const input = "nach -1000";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1000");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: bis 1786", () => {
        const input = "bis 1786";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("1786");
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

        expect(output.from).toBe("2010");
        expect(output.to).toBe("2015");
    });

    test("stringToDateRange :: 1001 bis 1500", () => {
        const input = "1001 bis 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1500");
    });

    test("stringToDateRange :: 1000 bis 1500", () => {
        const input = "1000 bis 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1000");
        expect(output.to).toBe("1500");
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

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("1500");
    });

    test("stringToDateRange :: vor 150", () => {
        const input = "vor 150";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("0150");
    });

    test("stringToDateRange :: vor 15", () => {
        const input = "vor 15";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe(undefined);
        expect(output.to).toBe("0015");
    });

    test("stringToDateRange :: nach 1500", () => {
        const input = "nach 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1500");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: nach 150", () => {
        const input = "nach 150";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0150");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: nach 15", () => {
        const input = "nach 15";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("0015");
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: um 1500", () => {
        const input = "um 1500";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1450");
        expect(output.to).toBe("1550");
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

    test("stringToDateRange :: 2. Jt. v. Chr.", () => {
        const input = "2. Jt. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1999");
        expect(output.to).toBe("-1000");
    });

    test("stringToDateRange :: 2. Jt.", () => {
        const input = "2. Jt.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("2000");
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

        expect(output.from).toBe("-0249");
        expect(output.to).toBe("0250");
    });

    test("stringToDateRange :: 2000 BC", () => {
        const input = "2000 BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1999");
        expect(output.to).toBe("-1999");
    });

    test("stringToDateRange :: 2000 AD", () => {
        const input = "2000 AD";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2000");
        expect(output.to).toBe("2000");
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

        expect(output.from).toBe("-0499");
        expect(output.to).toBe("-0400");
    });

    test("stringToDateRange :: 5. Jhd. vor Chr.", () => {
        const input = "5. Jhd. vor Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0499");
        expect(output.to).toBe("-0400");
    });

    test("stringToDateRange :: 5. Jhd. v. Chr.", () => {
        const input = "5. Jhd. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0499");
        expect(output.to).toBe("-0400");
    });

    test("stringToDateRange :: 554 v. Chr. - 62 n. Chr.", () => {
        const input = "554 v. Chr. - 62 n. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0553");
        expect(output.to).toBe("0062");
    });

    test("stringToDateRange :: 311 - 289 BC", () => {
        const input = "311 - 289 BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0310");
        expect(output.to).toBe("-0288");
    });

    test("stringToDateRange :: 311 - 289 v. Chr.", () => {
        const input = "311 - 289 v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0310");
        expect(output.to).toBe("-0288");
    });

    test("stringToDateRange :: 311 - 289 B.C.", () => {
        const input = "311 - 289 B.C.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0310");
        expect(output.to).toBe("-0288");
    });

    test("stringToDateRange :: 543 BC - 876 nach Chr.", () => {
        const input = "543 BC - 876 nach Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0542");
        expect(output.to).toBe("0876");
    });

    test("stringToDateRange :: 123 BC - 678 CE", () => {
        const input = "123 BC - 678 CE";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0122");
        expect(output.to).toBe("0678");
    });

    test("stringToDateRange :: 800 bc - 900 ad", () => {
        const input = "800 bc - 900 ad";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0799");
        expect(output.to).toBe("0900");
    });

    test("stringToDateRange :: 800 ac - 900 ad", () => {
        const input = "800 ac - 900 ad";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0799");
        expect(output.to).toBe("0900");
    });

    test("stringToDateRange :: 12 Jhd ac", () => {
        const input = "12 Jhd ac";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-1199");
        expect(output.to).toBe("-1100");
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
        expect(output.to).toBe(undefined);
    });

    test("stringToDateRange :: 21 B.C. - 10", () => {
        const input = "21 B.C. to 10";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0020");
        expect(output.to).toBe("0010");
    });

    test("stringToDateRange :: 1 jhd. v. chr.", () => {
        const input = "1 jhd. v. chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0099");
        expect(output.to).toBe("0000");
    });

    test("stringToDateRange :: 21 - 11 B.C.", () => {
        const input = "21 - 11 B.C.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0020");
        expect(output.to).toBe("-0010");
    });

    test("stringToDateRange :: 21 - 11 B.C.", () => {
        const input = "21 - 11 B.C.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0020");
        expect(output.to).toBe("-0010");
    });

    test("stringToDateRange :: 19th century - 20th century", () => {
        const input = "19th century - 20th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1801");
        expect(output.to).toBe("2000");
    });

    test("stringToDateRange :: 11. Jhd. - 12. Jhd.", () => {
        const input = "11. Jhd. - 12. Jhd.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 11 Jhd. - 12 Jhd.", () => {
        const input = "11 Jhd. - 12 Jhd.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 11. Jhd - 12. Jhd", () => {
        const input = "11. Jhd - 12. Jhd";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 11 Jhd - 12 Jhd", () => {
        const input = "11 Jhd - 12 Jhd";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 11 Jh. - 12 Jh.", () => {
        const input = "11 Jh. - 12 Jh.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 11 Jh - 12 Jh", () => {
        const input = "11 Jh - 12 Jh";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 11. Jh. - 12. Jh.", () => {
        const input = "11. Jh. - 12. Jh.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 11. Jh - 12. Jh", () => {
        const input = "11. Jh - 12. Jh";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("1001");
        expect(output.to).toBe("1200");
    });

    test("stringToDateRange :: 1. Jhd. v. Chr. - 1. Jhd.", () => {
        const input = "1. Jhd. v. Chr. - 1. Jhd.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0099");
        expect(output.to).toBe("0100");
    });

    test("stringToDateRange :: 1 Jhd. v. Chr. - 1 Jhd.", () => {
        const input = "1 Jhd. v. Chr. - 1 Jhd.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0099");
        expect(output.to).toBe("0100");
    });

    test("stringToDateRange :: 2. Jhd. v. Chr. - 1. Jhd. v. Chr.", () => {
        const input = "2. Jhd. v. Chr. - 1. Jhd. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0199");
        expect(output.to).toBe("0000");
    });

    test("stringToDateRange :: 2 Jhd. v. Chr. - 1 Jhd. v. Chr.", () => {
        const input = "2 Jhd. v. Chr. - 1 Jhd. v. Chr.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0199");
        expect(output.to).toBe("0000");
    });

    test("stringToDateRange :: 1th century BC - 1th century", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "1th century BC - 1th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0099");
        expect(output.to).toBe("0100");
    });

    test("stringToDateRange :: 1th century B.C. - 1th century", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "1th century B.C. - 1th century";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0099");
        expect(output.to).toBe("0100");
    });

    test("stringToDateRange :: 2th century BC - 1th century BC", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "2th century BC - 1th century BC";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0199");
        expect(output.to).toBe("0000");
    });

    test("stringToDateRange :: 2th century B.C. - 1th century B.C.", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "2th century B.C. - 1th century B.C.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0199");
        expect(output.to).toBe("0000");
    });

    test("stringToDateRange :: 1. Jhd. v. Chr. - 2. Jhd.", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "1. Jhd. v. Chr. - 2. Jhd.";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0099");
        expect(output.to).toBe("0200");
    });

    test("stringToDateRange :: August 2020", () => {
        CUI.DateTime.setLocale("en-US")
        const input = "August 2020";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2020-08-01");
        expect(output.to).toBe("2020-08-31");
    });

    test("stringToDateRange :: Oktober 2020", () => {
        CUI.DateTime.setLocale("de-DE")
        const input = "Oktober 2020";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("2020-10-01");
        expect(output.to).toBe("2020-10-31");
    });

    test("stringToDateRange :: -2020-11-05T11:00:00+01:00", () => {
        CUI.DateTime.setLocale("de-DE")
        const input = "-2020-11-05T11:00:00+01:00";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-2020-11-05");
        expect(output.to).toBe("-2020-11-05");
    });


    test("stringToDateRange :: -0100-01-01", () => {
        CUI.DateTime.setLocale("de-DE")
        const input = "-0100-01-01";

        const output = CUI.DateTime.stringToDateRange(input)

        expect(output.from).toBe("-0100-01-01");
        expect(output.to).toBe("-0100-01-01");
    });
});

describe('CUI.DateTime.dateRangeToString', () => {
    beforeEach(() => {
        CUI.DateTime.setLocale("de-DE")
    });

    test("dateRangeToString :: Invalid case", () => {
        const from = null
        const to = null

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBeUndefined()
    });

    test("dateRangeToString :: Invalid date (text)", () => {
        const from = "invalid-case"
        const to = null

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Datum ungültig")
    });

    test("dateRangeToString :: Just 'from' date", () => {
        const from = "2500-12-20"
        const to = null

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe(from)
    });

    test("dateRangeToString :: Just 'to' date", () => {
        const from = null
        const to = "2500-12-20"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe(to)
    });

    test("dateRangeToString :: 2000 - 2000", () => {
        const from = "2000"
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2000")
    });

    test("dateRangeToString :: 2000 - ", () => {
        const from = "2000"
        const to = null

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 2000")
    });

    test("dateRangeToString :: 2000 - 2500-12-20", () => {
        const from = "2000"
        const to = "2500-12-20"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2000 - 2500-12-20")
    });

    test("dateRangeToString :: 2000 - 2500", () => {
        const from = "2000"
        const to = undefined

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 2000")
    });

    test("dateRangeToString :: 2000-01-01 - 2000-01-01", () => {
        const from = "2000-01-01"
        const to = "2000-01-01"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("01.01.2000")
    });

    test("dateRangeToString :: 2000-01-01 - 2500-12-31", () => {
        const from = "2000-01-01"
        const to = "2500-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("01.01.2000 bis 31.12.2500")
    });

    test("dateRangeToString :: 1900 - 1950", () => {
        const from = "1900"
        const to = undefined

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1900")
    });

    test("dateRangeToString :: 1950 - 1965", () => {
        const from = "1950"
        const to = undefined

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1950")
    });

    test("dateRangeToString :: 1910 - 1915", () => {
        const from = "1910"
        const to = undefined

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1910")
    });

    test("dateRangeToString :: 1999 - 2001", () => {
        const from = "1999"
        const to = undefined

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1999")
    });

    test("dateRangeToString :: -1000 - -0500", () => {
        const from = "-1000"
        const to = undefined

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("nach 1000 v. Chr.")
    });

    test("dateRangeToString :: 1500 - 2000", () => {
        const from = undefined
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 2000")
    });

    test("dateRangeToString :: 1850 - 1900", () => {
        const from = undefined
        const to = "1900"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 1900")
    });

    test("dateRangeToString :: 1935 - 1950", () => {
        const from = undefined
        const to = "1900"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 1900")
    });

    test("dateRangeToString :: 1965 - 1970", () => {
        const from = undefined
        const to = "1970"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 1970")
    });

    test("dateRangeToString :: -0665 - -0660", () => {
        const from = undefined
        const to = "-0660"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("vor 660 v. Chr.")
    });

    test("dateRangeToString :: 1500 - 2500", () => {
        const from = "1500"
        const to = "2500"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 2000")
    });

    test("dateRangeToString :: 1935 - 1965", () => {
        const from = "1935"
        const to = "1965"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 1950")
    });

    test("dateRangeToString :: 1935 - 1965", () => {
        const from = "1905"
        const to = "1915"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("um 1910")
    });

    test("dateRangeToString :: 1997 - 2001", () => {
        const from = "1997"
        const to = "2001"

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

    test("dateRangeToString :: -0499 - -0400", () => {
        const from = "-0499"
        const to = "-0400"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("5. Jhd. v. Chr.")
    });

    test("dateRangeToString :: -0505 - -0406", () => {
        const from = "-0505"
        const to = "-0406"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("506 - 407 B.C.")
    });

    test("dateRangeToString :: 0401 - 0500", () => {
        const from = "0401"
        const to = "0500"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("5. Jhd.")
    });

    test("dateRangeToString :: -1600 - -1585", () => {
        const from = "-1599"
        const to = "-1584"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Anfang 16. Jh. v. Chr.")
    });

    test("dateRangeToString :: 1501 - 1516", () => {
        const from = "1501"
        const to = "1516"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Anfang 16. Jh.")
    });

    test("dateRangeToString :: 1501 - 1516", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1501"
        const to = "1516"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Early 16th century")
    });

    test("dateRangeToString :: -1216 - -1201", () => {
        const from = "-1214"
        const to = "-1199"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Ende 13. Jh. v. Chr.")
    });

    test("dateRangeToString :: 1285 - 1300", () => {
        const from = "1285"
        const to = "1300"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Ende 13. Jh.")
    });

    test("dateRangeToString :: 1285 - 1285", () => {
        const from = "1285"
        const to = "1285"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1285")
    });

    test("dateRangeToString :: 1285 - 1285-05-31", () => {
        const from = "1285"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1285 - 1285-05-31")
    });

    test("dateRangeToString :: 1285 - 1285-05-31 [US]", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1285-03-01"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1285-03-01 to 1285-05-31")
    });

    test("dateRangeToString :: Invalid date (non existing date)", () => {
        const from = "2222-22-22"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Datum ungültig")
    });

    test("dateRangeToString :: Invalid date (non existing date) (english)", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "2222-22-22"
        const to = "1285-05-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Invalid Date")
    });

    test("dateRangeToString :: 1285 - 1285-01-31", () => {
        const from = "1285"
        const to = "1285-01-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("Januar 1285")
    });

    test("dateRangeToString :: 1285 - 1285-01-31 [US]", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1285"
        const to = "1285-01-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("January 1285")
    });

    test("dateRangeToString :: 1901 - 2000", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1901"
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("20th century")
    });

    test("dateRangeToString :: -0010 - 10", () => {
        const from = "-0010"
        const to = "+10"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("11 B.C. - 10")
    });

    test("dateRangeToString :: -0020 - -10", () => {
        const from = "-0020"
        const to = "-10"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("21 - 11 B.C.")
    });

    test("dateRangeToString :: -0020 - 0010", () => {
        const from = "-0020"
        const to = "0010"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("21 B.C. - 10")
    });

    test("dateRangeToString :: 0100 - 2010-12-31", () => {
        const from = "0100"
        const to = "2010-12-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("100 - 2010-12-31")
    });

    test("dateRangeToString :: 0100 - 2010-01-29", () => {
        const from = "0100"
        const to = "2010-01-29"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("100 - 2010-01-29")
    });

    test("dateRangeToString :: -0099 - 0000", () => {
        const from = "-0099"
        const to = "0000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1. Jhd. v. Chr.")
    });

    test("dateRangeToString :: 1001 - 2000", () => {
        const from = "1001"
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2. Jt.")
    });

    test("dateRangeToString :: 1801 - 2000", () => {
        const from = "1801"
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("19. Jhd. – 20. Jhd.")
    });

    test("dateRangeToString :: 1801 - 2000 [US]", () => {
        CUI.DateTime.setLocale("en-US")
        const from = "1801"
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("19th century – 20th century")
    });

    test("dateRangeToString :: 1802 - 2000", () => {
        const from = "1802"
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1802 bis 2000")
    });

    test("dateRangeToString :: 1799 - 2000", () => {
        const from = "1799"
        const to = "2000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1799 bis 2000")
    });

    test("dateRangeToString :: -0099 - 0205", () => {
        const from = "-0099"
        const to = "0205"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("100 B.C. - 205")
    });

    test("dateRangeToString :: 2020-08-01 - 2020-08-31", () => {
        const from = "2020-08-01"
        const to = "2020-08-31"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("August 2020")
    });

    test("dateRangeToString :: -0199 - 0000", () => {
        CUI.DateTime.setLocale("de-DE")

        const from = "-0199"
        const to = "0000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2. Jhd. v. Chr. – 1. Jhd. v. Chr.")
    });

    test("dateRangeToString :: -0199 – -0099", () => {
        CUI.DateTime.setLocale("de-DE")

        const from = "-0199"
        const to = "-0100"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2. Jhd. v. Chr.")
    });

    test("dateRangeToString :: -0099 - 0000", () => {
        CUI.DateTime.setLocale("de-DE")

        const from = "-0099"
        const to = "0000"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("1. Jhd. v. Chr.")
    });

    test("dateRangeToString :: -0199 – 0100", () => {
        CUI.DateTime.setLocale("de-DE")

        const from = "-0199"
        const to = "0100"

        const output = CUI.DateTime.dateRangeToString(from, to)

        expect(output).toBe("2. Jhd. v. Chr. – 1. Jhd.")
    });
});