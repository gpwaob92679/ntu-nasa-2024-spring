<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Image Sharing Server</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    </head>
    <body class="bg-dark text-white">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <br>
                    <br>
                    <h1>Image Sharing Server</h1>
                    <br>
                    <br>
                    <form action="upload.php" method="post" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label for="image" class="form-label">Select Image</label>
                            <input type="file" class="form-control" id="image" name="file">
                        </div>
                        <button type="submit" class="btn btn-primary">Upload</button>
                    </form>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <br>
                    <br>
                    <h2>Shared Images</h2>
                    <br>
                    <div class="container">
                        <?php 
                            $files = scandir('uploads');
                            foreach ($files as $file) {
                                if ($file != '.' && $file != '..') {
                                    echo '<img src="uploads/' . $file . '" class="img-thumbnail" style="width: 200px; height: 200px; margin: 10px;">';
                                }
                            }
                        ?>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    </body>
</html>
    
