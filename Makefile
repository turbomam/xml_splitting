del_from = 101

.PHONY: all clean

all: target/clean biosample_set_under_$(del_from)_noclose.xml

clean:
	rm -f biosample_set_under_$(del_from)_noclose.xml

# ~1.5 GB, so ~ 1 minute @ 200 Mbps connection
download/biosample_set.xml.gz:
	wget https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz -O $@

# ~ 3 minutes on Intel Core i7-10710U + budget NVMe SSD
target/biosample_set.xml: download/biosample_set.xml.gz
	gunzip -c $< > $@

target/biosample_set_under_$(del_from)_noclose.xml: target/biosample_set.xml
	# GNU sed 4.7
	sed '/^<BioSample.*id="$(del_from)"/q'  $< > $@

