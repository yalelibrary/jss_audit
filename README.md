# jss_audit
## Rake tasks:
 - lib/tasks/jss_audit.rake
 - Python audit scripts to compare pids in two csv: one output from federoa image server, another one is the output of solr query for page level pids. import_csv.py check fedora images output against solr page level pids
 
- JSS images audit scripts and download script

## The follow scripts
(1,2,3,4,6 are in https://github.com/yalelibrary/jss_audit/blob/master/lib/tasks/jss_audit.rake) 

1.  Title level bibs  run `rake jss_solr:titleBIDs` or `rake jss_solr:titleBIDs >> title_bibs"

2. Volume level pids and output the pids into a comma separated csv  run  `rake jss_solr:volume >> volume_pids'

3. Page level pids and output the pids into a csv  run `page_children_csv >> 'jss_page_pids'

4. Scan the fedora file system to get the list of JPG/PDF  run `rake jss_solr:scan_file_system >> fedora_server'

5. https://github.com/yalelibrary/jss_audit/blob/master/import_csv.py audit if all images are in the fedora file system run  `python 3 import_csv.py' Note: panda runs on python3

6. download the children images of each volume level pids, and save the children images in the folder named as volume-level pids run `rake jss_solr:download_all_images` 

    Replace `/Users/LixiaZhao/good/jss_task/` with the destinated folder (this is to get JPG, replace JPG to PDF will get pdf files)
    
    
    Notice: ":" in pids have to be replaced for solr query and when mkdir as the def download_all_images does
