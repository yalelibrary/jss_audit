# jss_audit
JSS images audit scripts and download script

This script is to get the list of:
1. Title level bibs  run `rake jss_solr:titleBIDs` or `rake jss_solr:titleBIDs >> title_bibs"
2. Volume level pids and output the pids into a comma separated csv  run `rake jss_solr:volume >> volume_pids'
3. Page level pids and output the pids into a csv  run 'page_children_csv >> 'jss_page_pids'
4. Scan the fedora file system to get the list of JPG/PDF  run `rake jss_solr:scan_file_system >> fedora_server'
5. audit if all images are in the fedora file system run  'python 3 import_csv.py'
6. download the children images of each volume level pids, and save the children images in the folder named as volume-level pids run `rake jss_solr:download_all_images` 
    Replace the destinated folder (this is to get JPG, replace JPG to PDF will get pdf files)
    Notice: ":" in pids have to be replaced for solr query and when mkdir as the def download_all_images does
