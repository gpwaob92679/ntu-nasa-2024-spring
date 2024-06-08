<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $uploadDir = '/var/www/html/uploads';

    // Check if the upload directory exists, create it if not
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $uploadedFile = $_FILES['file'];

    $uploadedFileName = $uploadedFile['name'];
    $uploadedFileExtension = strtolower(pathinfo($uploadedFileName, PATHINFO_EXTENSION));
    $uniqueFileName = uniqid() . '.' . $uploadedFileExtension;
    $destination = $uploadDir . '/' . $uniqueFileName;

    // Move the uploaded file to the destination directory
    if (move_uploaded_file($uploadedFile['tmp_name'], $destination)) {
        // File uploaded successfully
        echo "File uploaded at $destination successfully.";
    } else {
        // Failed to move the uploaded file
        echo 'Failed to upload file.';
    }
}
?>
