*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the website
    Get order list
    Close popup
    ${orders}=    Read table from CSV    orders.csv
    ${row}=    Get Table Row    ${orders}    1
    Fill the form    ${row}
    Preview order
    # Wait Until Keyword Succeeds    1 min    1 sec    Submit order
    Store the receipt as a PDF file    ${row}[Order number]
    # Take a screenshot of the robot
    # FOR    ${row}    IN    @{orders}
    #    Close popup
    #    Fill the form ${row}
    # [Teardown]    Log out and close the browser

*** Keywords ***
Open the website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get order list
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Close popup
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    Select From List By Value    name:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview order
    Click Button    preview

Submit order
    Click Button    order

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:receipt
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${OUTPUT_DIR}${/}${receipts}${/}${order_number}.pdf


# Take a screenshot of the robot