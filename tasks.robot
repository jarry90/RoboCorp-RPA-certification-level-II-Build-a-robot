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
Library           RPA.Archive

*** Variables ***
${robot_receipt}=    ${OUTPUT_DIR}${/}temporary${/}order.pdf
${robot_screenshot}=    ${OUTPUT_DIR}${/}temporary${/}screenshot.png

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Get order list
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{orders}
        Open the website
        Close popup
        Fill the form    ${row}
        Fill the form    ${row}
        Preview order
        Wait Until Keyword Succeeds    1 min    1 sec    Submit order
        Store the receipt as a PDF file    ${row}[Order number]
        Take a screenshot of the robot    ${row}[Order number]
        Embed screenshot to receipt PDF    ${row}[Order number]
        Close All Browsers
    END
    ZIP receipts together

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
    Element Should Be Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${robot_receipt}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Screenshot    robot-preview-image    ${robot_screenshot}

Embed screenshot to receipt PDF
    [Arguments]    ${order_number}
    ${files}=    Create List
    ...    ${robot_receipt}
    ...    ${robot_screenshot}
    Add Files To PDF    ${files}    ${OUTPUT_DIR}${/}receipts${/}${order_number}.pdf

ZIP receipts together
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}receipts${/}
    ...    ${OUTPUT_DIR}${/}receipts.zip
