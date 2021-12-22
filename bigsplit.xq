for $bs in doc('target/biosample_set.xml')/BioSampleSet/BioSample let $id := data($bs/@id) where $id < 11 return $bs
