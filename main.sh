# This package is outdated (from 2023), not recommended
# apt-get install yt-dlp -y
#
# Download the official binary to a location accessible by all users (including www-data)
wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp

# Make the binary executable for all users
chmod a+rx /usr/local/bin/yt-dlp

# Verify www-data user can execute it
# which yt-dlp  # debug
# sudo -u www-data /usr/local/bin/yt-dlp --version  # debug

# Without ffmpeg, yt-dlp downloads lower-quality formats; install it for merging and best quality.
apt-get update
apt-get install ffmpeg -y

# This issue is common—PHP processes (usually run as www-data) have limited permissions and environment variables.
# They typically can't access yt-dlp in your user directory (~/.local/bin).
# By default, home directories often have 700 permissions, blocking access for other users.
mkdir -p /var/www/yt-dlp
# Use the "get-cookiestxt-locally" browser extension to export cookies for YouTube and Bilibili.
# Then upload the exported file to: /var/www/yt-dlp/cookies.txt
# sftp vps-1
# put "path\to\cookies.txt" "/var/www/yt-dlp"

cp "./cookies.txt" "/var/www/yt-dlp"
cp "./download.html" "/var/www/yt-dlp"
cp "./download.php" "/var/www/yt-dlp"

chown -R www-data:www-data "/var/www/yt-dlp"

# Access the site to download videos:
https://domain.com/yt-dlp/download.html
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
YouTube Video Downloader
: <<'END'
<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button -->
<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="https://example.com/yt-dlp/download.html" target="_blank" rel="noreferrer noopener">Download</a></div>
<!-- /wp:button --></div>
<!-- /wp:buttons -->
END

