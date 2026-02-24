# This package is outdated (from 2023), not recommended
# apt-get install yt-dlp -y
#
# Download the official binary to a location accessible by all users (including www-data)
wget -q https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp >/dev/null

# Make the binary executable for all users
chmod a+rx /usr/local/bin/yt-dlp

# Verify www-data user can execute it
# which yt-dlp  # debug
# sudo -u www-data /usr/local/bin/yt-dlp --version  # debug

# Without ffmpeg, yt-dlp downloads lower-quality formats; install it for merging and best quality.
apt-get update >/dev/null
apt-get install ffmpeg -y >/dev/null

# This issue is common—PHP processes (usually run as www-data) have limited permissions and environment variables.
# They typically can't access yt-dlp in your user directory (~/.local/bin).
# By default, home directories often have 700 permissions, blocking access for other users.
mkdir -p /var/www/yt-dlp
# Use the "get-cookiestxt-locally" browser extension to export cookies for YouTube and Bilibili.
# Then upload the exported file to: /var/www/yt-dlp/cookies.txt
# sftp vps-1
# put "path\to\cookies.txt" "/var/www/yt-dlp"
# Cookie handling policy:
# Do NOT manually create an empty cookies.txt file. In normal cases, do not upload cookies at all.
# If cookies.txt does not exist, yt-dlp will automatically create a valid Netscape-format cookies 
# file and update it dynamically based on the website being accessed.
# For example:
# - When downloading from site-a, yt-dlp will generate and store the required site-a cookies.
# - When downloading from site-b, yt-dlp will append the necessary site-b cookies to the same file.
# yt-dlp automatically maintains and updates the cookies file per domain as needed.
#
# Only upload a manually exported cookies file (via browser export + SFTP) if:
# - The video requires a logged-in account (e.g. membership-only content), or
# - The IP address is restricted and authentication is required.
# Otherwise, allow yt-dlp to auto-generate and manage cookies.txt.
#
# IMPORTANT:
# yt-dlp WILL automatically maintain and update cookies.txt,
# even if the file was manually uploaded, as long as file
# permissions allow write access.
#
# If cookies.txt is owned by root (or not writable by the
# runtime user), yt-dlp cannot modify it.
#
# In a typical PHP environment, yt-dlp runs as www-data,
# not root. Therefore, cookies.txt must be writable by www-data.
#
# Example:
# chown www-data:www-data /var/www/yt-dlp/cookies.txt
# chmod 664 /var/www/yt-dlp/cookies.txt
# The first line of cookies.txt usually contains:
# "# Netscape HTTP Cookie File"
# This header declares that the file follows the standard
# Netscape HTTP cookie file format.
# In most cases, it is recommended to let yt-dlp generate and manage
# cookies.txt automatically.

# cp "./cookies-sample.txt" "/var/www/yt-dlp/cookies.txt"
# Root cause of download failure:
# yt-dlp was failing because an empty cookies.txt file was manually created.
# Although the file existed, it was NOT in valid Netscape cookie format.
# When --cookies points to an existing file, yt-dlp strictly validates its format.
# An empty file triggers: ERROR: '<path>/cookies.txt' does not look like a Netscape format cookies file
# Solution:
# - Either upload a properly formatted Netscape cookies file,
# - Or do NOT create a cookies.txt file at all.
# If the cookies file does not exist, yt-dlp will automatically
# generate a valid Netscape-format cookies.txt when needed.
# In short:
# Never create an empty cookies.txt file. An empty file fails format validation
# and also prevents yt-dlp from generating a valid cookies file automatically.

cp "./download.html" "/var/www/yt-dlp"
cp "./download.php" "/var/www/yt-dlp"

chown -R www-data:www-data "/var/www/yt-dlp"
# tail -f /var/log/nginx/example.com.error.log  # debug
# Access the site to download videos:
# https://domain.com/yt-dlp/download.html
# The URL has a trailing slash "/"  
# download.html is a file, not a directory  
# Using download.html/ makes the server treat it as a directory  
# This usually causes an automatic redirect to the homepage or a 404 error  

# yt-dlp will read this cookies file to access the corresponding websites,
# allowing it to bypass login requirements, anti-bot protection, and restrictions.

# The cookies file is not site-separated. In most cases, a single cookies.txt file can include cookies from multiple sites.
# yt-dlp will automatically match the appropriate cookies based on the URL being accessed.

# The browser can prompt a download dialog,
# but if the download doesn’t start, it’s likely a certificate issue— the certificate needs to be trusted.

# Test downloading the video with curl to check for errors:
# curl -v -L -O "https://domain.com/downloads/yt_682609212eda94.41831598.mp4"

# Option 1: Ignore certificate errors with curl for quick testing:
# curl -v -k -L -O "https://domain.com/downloads/yt_682609212eda94.41831598.mp4"

# If this works, the download failure is caused by an invalid HTTPS certificate.
# Double-click the certificate to import it into Trusted Root Certification Authorities.

# For debug
# yt-dlp -P ~/ https://www.youtube.com/watch?v=NyUTYwZe_l4
# sudo -u www-data /usr/local/bin/yt-dlp -o /var/www/wordpress/downloads/test.%(ext)s 'https://www.youtube.com/watch?v=NyUTYwZe_l4'

# HTML code for a video downloader page with an automatic redirection.
# YouTube Video Downloader
: <<'END'
<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="https://example.com/yt-dlp/download.html" target="_blank" rel="noreferrer noopener">Download</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->
END
