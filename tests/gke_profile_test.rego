package tdx_test

import rego.v1

quote := data.fixtures.gke_c3_cos

test_gke_profile_accepts if {
	data.tdx.allow with input as quote
}

test_default_still_rejects_gke if {
	not data.tdx.allow with input as quote with data.reference_values as {}
}

test_wrong_owner_rejected if {
	altered := object.union(quote, {"mrowner": "bad"})
	not data.tdx.allow with input as altered
}

test_previous_node_owner_rejected if {
	altered := object.union(quote, {"mrowner": "cc072416fb871191d450742adcef3ed548a17293d1f5d9dd02e8c1ce240129f20d411d99c7bf91c128dba6d10fdb7231"})
	not data.tdx.allow with input as altered
}

test_wrong_boot_rejected if {
	altered := object.union(quote, {"mrtd": "bad"})
	not data.tdx.allow with input as altered
}

test_wrong_module_rejected if {
	altered := object.union(quote, {"mrseam": "bad"})
	not data.tdx.allow with input as altered
}

test_runtime_measurement_change_rejected if {
	altered := object.union(quote, {"rtmr": array.concat(array.slice(quote.rtmr, 0, 3), ["bad"])})
	not data.tdx.allow with input as altered
}

test_minor_svn_rollback_rejected if {
	altered := object.union(quote, {"tee_tcb_svn": [14, 1, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]})
	not data.tdx.allow with input as altered
}

test_major_series_mismatch_rejected if {
	altered := object.union(quote, {"tee_tcb_svn": [15, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]})
	not data.tdx.allow with input as altered
}

test_debug_rejected if {
	altered := object.union(quote, {"tdattributes": [1, 0, 0, 16, 0, 0, 0, 0]})
	not data.tdx.allow with input as altered
}

test_unexpected_attributes_rejected if {
	altered := object.union(quote, {"tdattributes": [0, 0, 0, 16, 1, 0, 0, 0]})
	not data.tdx.allow with input as altered
}

test_unexpected_cpu_features_rejected if {
	altered := object.union(quote, {"xfam": [255, 2, 6, 0, 0, 0, 0, 0]})
	not data.tdx.allow with input as altered
}

test_default_azure_baseline_accepts if {
	azure := object.union(quote, {
		"mrowner": "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
		"tee_tcb_svn": [7, 3, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	})
	data.tdx.allow with input as azure with data.reference_values as {}
}
