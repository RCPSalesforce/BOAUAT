    /*
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: #333 !important;
            color: white !important;
            font-weight: bold !important;
        }

        td,
        th {
            padding: 6px;
            border: 1px solid #ccc;
            text-align: left;
        }
    */

    /* 
Max width before this PARTICULAR table gets nasty
This query will take effect for any screen smaller than 760px
and also iPads specifically.
*/

    @media only screen and (max-width: 760px), (min-device-width: 768px) and (max-device-width: 1024px) {
        /* Force table to not be like tables anymore */
        table, thead, tbody, th, td, tr {
            display: block;
        }
        /* Hide table headers (but not display: none;, for accessibility) */
        thead tr {
            position: absolute;
            top: -9999px;
            left: -9999px;
        }
        tr {
            border: 1px solid #ccc;
        }
        td {
            border: none;
            border-bottom: 1px solid #eee;
            position: relative !important;
            padding-left: 40% !important;
            display: flex;
            justify-content: center;
            padding-bottom: 1rem !important;
            background: #fff !important;
        }
        td:before {
            /* Now like a table header */
            position: absolute;
            /* Top/left values mimic padding */
            top: 28px;
            left: 9px;
            width: 45%;
            padding-right: 10px;
            white-space: nowrap;
            box-shadow: none !important;
        }
        /*
            Label the data
            */
        td:nth-of-type(1):before {
            content: "";
        }
        td:nth-of-type(2):before {
            content: "Name";
        }
        td:nth-of-type(3):before {
            content: "QUANTITY";
        }
        td:nth-of-type(4):before {
            content: "DESCRP";
        }
        td:nth-of-type(5):before {
            content: "UNIT PRICE";
        }
        td:nth-of-type(6):before {
            content: "SALES PRICE";
        }
        td:nth-of-type(7):before {
            content: "FULL B/C";
        }
        td:nth-of-type(8):before {
            content: "DISCOUNT";
        }
        td:nth-of-type(9):before {
            content: "TOTAL";
            top: 15px;
        }
        td:nth-of-type(10):before {
            content: "LOC CNT";
        }
        td:nth-of-type(11):before {
            content: "";
        }
    }