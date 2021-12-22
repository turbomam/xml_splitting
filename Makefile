# developed on Ubuntu 20.04.3 LTS
# dependencies: wget, gunzip, sed (used GNU sed 4.7)

# Saxon-HE (see installation example below)
#   even with huge memory, Saxon-HE can't load all of biosample
#   Fatal error during query: java.lang.IllegalStateException: Source document too large: more than 1G characters in text nodes
#   see also
#   https://sourceforge.net/p/saxon/mailman/saxon-help/thread/CAE35VmxtWqCeco-Ne=WZkTCrz+mdG0jcuWQqmhw-Fn5MQ+4BvA@mail.gmail.com/

# Saxon-EE ~ $400 might be ble to do it in streaming mode
#   there is a trail period

# http://www.stylusstudio.com/buy/
# http://qxmledit.org/info.html
#   open source GUI for Win ans Mac?
# https://xponentsoftware.com/xmlSplit.aspx
# https://github.com/eXist-db/exist/releases/tag/eXist-4.8.0
# https://stackoverflow.com/questions/70442304/split-xml-after-n-instances-of-the-same-element
# https://stackoverflow.com/questions/700213/xml-split-of-a-large-file
# https://docs.basex.org/wiki/Statistics
#   BaseX database limits

# 24290820
# 25000000
# 12500000

# assumes that the specified id is present in the input
del_from = 12500001
biosample_url = https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz

.PHONY: all clean

all: clean target/biosample_set_under_$(del_from).xml target/biosample_set_over_$(del_from).xml

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
	# two minutes when retrieving 12500000 lines
	date
	sed '/^<BioSample.*id="$(del_from)"/q'  $< > $@
	# below might not require deletion of trailing line
	# not that that's a slow step
	#sed '/^<BioSample.*id="$(del_from)"/,$$d'  $< > $@
	date

target/biosample_set_under_$(del_from).xml: target/biosample_set_under_$(del_from)_noclose.xml
	# sed's q operator leaves the matching line
	# this deletes the unwanted matching line
	# note $$ escaping within make
	sed -i '$$d' $<
	# another two minutes when retrieving 12500000 lines
	cat $< biosample_set_closer.txt > $@
	rm -f $<

target/biosample_set_over_$(del_from)_noopen.xml: target/biosample_set.xml
	sed -n '/^<BioSample.*id="$(del_from)"/,$$p'  $< > $@

target/biosample_set_over_$(del_from).xml: target/biosample_set_over_$(del_from)_noopen.xml
	cat biosample_set_opener.txt $< > $@
	rm -f $<


# java -cp saxon/saxon-he-10.6.jar net.sf.saxon.Query split.xq
# java -cp saxon/saxon-he-10.6.jar net.sf.saxon.Query -qs:'for $bs in doc("target/biosample_set_under_101.xml")/BioSampleSet/BioSample let $id := data($bs/@id) where $id < 11 return $bs