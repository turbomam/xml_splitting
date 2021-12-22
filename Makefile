# developed on Ubuntu 20.04.3 LTS
# dependencies: wget, gunzip, sed (used GNU sed 4.7)

del_from = 1001
biosample_url = https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz

.PHONY: all clean

all: clean target/biosample_set_under_$(del_from).xml

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
	cat $< biosample_set_closer.txt > $@
	rm -f $<
