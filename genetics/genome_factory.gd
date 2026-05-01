class_name GenomeFactory
extends RefCounted


static func from_seed(seed: int, gene_config: GeneConfig) -> Genome:
	var genome := Genome.new()
	genome.seed = max(1, abs(seed))

	var rng := SeededRng.new(genome.seed)
	var values := {}
	for schema in gene_config.schemas:
		values[schema.gene_id] = schema.random_value(rng)

	genome.gene_values = gene_config.clamp_gene_values(values)
	return genome
