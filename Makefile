# developed on Ubuntu 20.04.3 LTS
# dependencies: wget, gunzip, sed (used GNU sed 4.7), Saxon-HE (see installation example below)
# sudo apt-get install libsaxonhe-java
#   no jar file


del_from = 101
biosample_url = https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz

.PHONY: all clean

all: clean target/biosample_set_under_$(del_from).xml

download/SaxonHE10-6J.zip:
	wget https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/SaxonHE10-6J.zip -O $@
	unzip -d saxon $@ >

clean:
	rm -f target/biosample_set_under_$(del_from)*.xml

download/biosample_set.xml.gz:
	# ~1.5 GB, so ~ 1 minute @ 200 Mbps connection
	wget $(biosample_url) -O $@

target/biosample_set.xml: download/biosample_set.xml.gz
	# ~ 3 minutes on Intel Core i7-10710U + budget NVMe SSD
	gunzip -c $< > $@

target/biosample_set_under_$(del_from)_noclose.xml: target/biosample_set.xml
	sed '/^<BioSample.*id="$(del_from)"/q'  $< > $@

target/biosample_set_under_$(del_from).xml: target/biosample_set_under_$(del_from)_noclose.xml
	# sed's q operator leaves the matching line
	# this deletes the unwanted matching line
	# note $$ escaping within make
	sed -i '$$d' $<
	cat $< biosample_set_closer.txt > $@
	rm -f $<


#java -cp saxon/saxon-he-10.6.jar net.sf.saxon.Query split.xq
# java -cp saxon/saxon-he-10.6.jar net.sf.saxon.Query split.xq
# java -cp saxon/saxon-he-10.6.jar net.sf.saxon.Query -qs:'for $bs in doc("target/biosample_set_under_101.xml")/BioSampleSet/BioSample let $id := data($bs/@id) where $id < 11 return $bs