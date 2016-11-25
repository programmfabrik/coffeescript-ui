<!doctype html>
<meta charset="utf-8">
<title>Icons</title>
<style>
  html {
    padding: 0 14px 14px 0;
  }
  body {
    margin: 14px;
    background: hsl(210,14%,98%);
    font-family: sans-serif;
    font-size: 13px;
  }
  .filter {
    width: 100%;
    max-width: 400px;
    margin: 14px;
    appearance: none;
    background: none;
    padding: 10px 28px;
    border-radius: 999px;
    border: 1px solid hsl(199,44%,93%);
    box-shadow: 0 1px 1px hsl(210,7%,95%) inset;
    font-size: 24px;
    outline: none;
    font-weight: 300;
  }
  .filter::-webkit-input-placeholder { color: hsl(199,34%,80%); }
  .filter:-ms-input-placeholder      { color: hsl(199,34%,80%); }
  .filter::-moz-placeholder          { color: hsl(199,34%,80%); }
  .filter::placeholder               { color: hsl(199,34%,80%); }
  .icons {
    display: flex;
    flex-wrap: wrap;
    margin: 14px 14px 0 0;
  }
  .icon-holder {
    border: 1px solid hsl(199,44%,93%);
    box-shadow: 0 1px 1px hsl(210,7%,95%);
    margin: 0 0 14px 14px;
    display: flex;
    flex-direction: column;
  }
  .icon-holder.is-filtered {
    display: none;
  }
  .icon {
    flex: 1;
    position: relative;
    padding: 10px;
    width: 100%;
    box-sizing: border-box;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  .icon.is-light {
    background: hsl(210,14%,88%);
  }
  .icon svg {
    position: relative;
  }
  .icon-body {
    padding: 10px;
    display: flex;
    justify-content: center;
    background: white;
  }
  .icon-name {
    white-space: nowrap;
  }
</style>
<input class="filter" type="search" placeholder="Filter Icons">
<div class="icons">
<?

# Path to image folder
$imageFolder = '';

# Show only these file types from the image folder
$imageTypes = '{*.svg}';

# Set to true if you prefer sorting images by name
# If set to false, images will be sorted by date
$sortByImageName = false;

# Set to false if you want the oldest images to appear first
# This is only used if images are sorted by date (see above)
$newestImagesFirst = true;

date_default_timezone_set('Europe/Berlin');

# The rest of the code is technical

# Add images to array
# Exclude icons.svg
$images = glob($imageFolder . $imageTypes, GLOB_BRACE);

# Sort images
if ($sortByImageName) {
  $sortedImages = $images;
  natsort($sortedImages);
} else {
  # Sort the images based on its 'last modified' time stamp
  $sortedImages = array();
  $count = count($images);
  for ($i = 0; $i < $count; $i++) {
    $sortedImages[date('YmdHis', filemtime($images[$i])) . $i] = $images[$i];
  }
  # Sort images in array
  if ($newestImagesFirst) {
    krsort($sortedImages);
  } else {
    ksort($sortedImages);
  }
}
?>

<? foreach ($sortedImages as $image): ?>
<?
  # Get the name of the image, stripped from image folder path and file type extension
  $filename = basename($image);
  $name = preg_replace('/\\.[^.\\s]{3,4}$/', '', $filename);

  if($name == 'icons')
    continue;

  # Begin adding
?>
  <div class="icon-holder">
    <div class="icon">
      <?= file_get_contents($image) ?>
    </div>
    <form class="icon-body">
      <div class="icon-name"><?= $name ?></div>
    </form>
  </div>
<? endforeach ?>
</div>

<script>
  var names = document.querySelectorAll('.icon-name');

  document.querySelector('.filter').oninput = function(){
    for(var i=0; i<names.length; i++){
      var isFiltered = names[i].textContent.indexOf(this.value) == -1;
      names[i].parentNode.parentNode.classList.toggle('is-filtered', isFiltered);
    }
  }
</script>