document.addEventListener('DOMContentLoaded', function () {
    const downloadBtn = document.getElementById('download-receipt');
    const captureSection = document.getElementById('receipt');

    if (!downloadBtn || !captureSection) {
        console.error("Elements not found!");
        return;
    }


    downloadBtn.addEventListener('click', function () {
        const docDefinition = {
            content: [
                {
                    columns: [
                        { text: 'RECEIPT', style: 'header' }
                    ]
                },
                {
                    margin: [0, 10, 0, 10],
                    table: {
                        widths: ['50%', '50%'],
                        body: [
                            [
                                {
                                    stack: [
                                        { text: 'SmartEDU', style: 'company' },

                                        'Mahidol International University\n',
                                        'Nakhon Pathom, Salaya\n',
                                        '0998671165\n',
                                        'smarteduccc@gmail.com\n',
                                    ],
                                    border: [false, false, false, false]
                                },
                                {
                                    stack: [
                                        { text: 'PAYMENT DATE', style: 'boldLabel' },
                                        payment_created,
                                        { text: 'RECEIPT NO.', style: 'boldLabel' },
                                        payment_id
                                    ],
                                    alignment: 'right',
                                    border: [false, false, false, false]
                                }
                            ]
                        ]
                    }
                },
                {
                    margin: [0, 10, 0, 10],
                    table: {
                        widths: ['50%', '50%'],
                        body: [
                            [
                                {
                                    stack: [
                                        { text: 'BILL TO', style: 'sectionHeader' },
                                        payment_first_name + ' ' + payment_last_name,
                                        payment_email
                                    ],
                                    border: [false, false, false, false]
                                },
                                {
                                    stack: [
                                        { text: 'SUBSCRIPTION DETAILS', style: 'sectionHeader' },
                                        { text: 'Start Date:', style: 'boldLabel' },
                                        payment_subscription_start,
                                        { text: 'End Date:', style: 'boldLabel' },
                                        payment_subscription_end
                                    ],
                                    border: [false, false, false, false]
                                }
                            ]
                        ]
                    }
                },
                {
                    text: '\n'
                },
                {
                    table: {
                        headerRows: 1,
                        widths: ['60%', '40%'],
                        body: [
                            [
                                { text: 'DESCRIPTION', style: 'tableHeader', fillColor: '#142567', color: 'white' },
                                { text: 'AMOUNT', style: 'tableHeader', fillColor: '#142567', color: 'white' }
                            ],
                            [
                                { text: 'Subscription Payment', style: 'value' },
                                { text: payment_amount + " THB", style: 'value' , alignment: 'right'}
                            ]
                        ]
                    }
                },
                {
                    text: '\n'
                },
                {
                    table: {
                        widths: ['60%', '40%'],
                        body: [
                            [{ text: 'TOTAL AMOUNT', style: 'boldLabel' }, { text: payment_amount + "  THB", bold: true }]
                        ]
                    },
                    alignment: 'right'
                },
                {
                    text: '\n\nPaid:' +  "  " + payment_amount +  " THB" ,
                    style: 'footer'
                }
            ],
            styles: {
                header: { fontSize: 24, bold: true, marginBottom: 20, alignment: 'left' },
                company: { fontSize: 12, bold: true },
                boldLabel: { fontSize: 12, bold: true, marginBottom: 2 },
                sectionHeader: { fontSize: 14, bold: true, marginBottom: 5, decoration: 'underline' },
                tableHeader: { fontSize: 12, bold: true, alignment: 'center' },
                value: { fontSize: 12, marginBottom: 5 },
                footer: { fontSize: 12, italics: true, alignment: 'right' }
            }
        };


        pdfMake.createPdf(docDefinition).download('receipt.pdf');
    });
});
