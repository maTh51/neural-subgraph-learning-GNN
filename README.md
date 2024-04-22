# Aprendizado Descritivo - Seminário 3 - Papel 5

## Integrantes: 
### Fernanda Luiza Tobias, Gabriel Bifano Freddi, Hugo Parreiras Nunes Baraky, João Vítor Dos Santos Vaz, Joao Vitor Santana Depollo, Matheus Tiago Pimenta De Souza, Rodrigo Sales Nascimento, Vinicius Alves De Faria Resende

Este trabalho consiste em avaliações de trabalhos recentes na área de Aprendizado Descritivo, subtema de mineração de grafos frequentes. Link do artigo: https://arxiv.org/abs/2402.14367 .

## Como rodar o código via Docker:

Baixe ou copie o código do Dockerfile nesse repositório para a máquina de destino (não precisa necessariamente clonar o repositório, já que o docker fará isso). 

Edite o comando na última linha com a configuração necessária (em especial o dataset desejado). Em seguida, execute o comando:

```
docker build . -t spminer
```

Crie duas pastas: uma para o arquivo pickle com os resultados (e.g. results), e outra para as imagems (e.g. plots). Por fim, rode a imagem, passando essas pastas como volume:

```
docker run -v /caminho/para/results:/spminer/results -v /caminho/para/plots:/spminer/plots/cluster spminer
```

Por rodar na CPU, o tempo total de execução varia. Testes foram de 10 minutos (24 core) até 40.


# Neural Subgraph Learning Library

Neural Subgraph Learning (NSL) is a general library that implements various tasks related to
learning of subgraph relations.

It is able to perform 2 tasks:
1. Neural subgraph matching.
2. Frequent subgraph mining.

## Neural Subgraph Matching
The library implements the algorithm [NeuroMatch](http://snap.stanford.edu/subgraph-matching/).

### Problem setup
Given a query graph Q anchored at node q, and a target graph T anchored at node v,
predict if there exists an isomorphism mapping a subgraph of T to Q, such that the isomorphism maps
v to q.
The framework maps the query and target into an embedding space, and either uses MLP/Neural tensor network + cross entropy loss
or order embedding + max margin loss to obtain a prediction score and make the binary prediction of subgraph relationship based on a
threshold of the score.

See paper and website for detailed explanation of the algorithm.

### Train the matching GNN encoder
1. Train the encoder: `python3 -m subgraph_matching.train --node_anchored`. Note that a trained order embedding model checkpoint is provided in `ckpt/model.pt`.
2. Optionally, analyze the trained encoder via `python3 -m subgraph_matching.test --node_anchored`, or by running the "Analyze Embeddings" notebook in `analyze/`

By default, the encoder is trained with on-the-fly generated synthetic data (`--dataset=syn-balanced`). The dataset argument can be used to change to a real-world dataset (e.g. `--dataset=enzymes`), or an imbalanced class version of a dataset (e.g. `--dataset=syn-imbalanced`). It is recommended to train on a balanced dataset.

### Usage
The module `python3 -m subgraph_matching.alignment.py [--query_path=...] [--target_path=...]` provides a utility to obtain all pairs of corresponding matching scores, given a pickle file of the query and target graphs in networkx format. Run the module without these arguments for an example using random graphs. 
If exact isomorphism mapping is desired, a conflict resolution algorithm can be applied on the
alignment matrix (the output of alignment.py). 
Such algorithms are available in recent works. For example: [Deep Graph Matching
Consensus](https://arxiv.org/abs/2001.09621) and [Convolutional Set Matching for Graph
Similarity](https://arxiv.org/abs/1810.10866).

Both synthetic data (`common/combined_syn.py`) and real-world data (`common/data.py`) can be used to train the model.
One can also train with synthetic data, and transfer the learned model to make inference on real
data (see `subgraph_matching/test.py`).
The `neural_matching` folder contains an encoder that uses GNN to map the query and target into the
embedding space and make subgraph predictions.

Available configurations can be found in `subgraph_matching/config.py`.


## Frequent Subgraph Mining
This package also contains an implementation of SPMiner, a graph neural network based framework to extract frequent subgraph patterns from an input graph dataset.

Running the pipeline consists of training the encoder on synthetic data, then running the decoder on the dataset from which to mine patterns.

Full configuration options can be found in `subgraph_matching/config.py` and `subgraph_mining/config.py`.

### Run SPMiner
To run SPMiner to identify common subgraph pattern, the prerequisite is to have a checkpoint of
trained subgraph matching model (obtained by training the GNN encoder).
The config argument `args.model_path` (`subgraph_matching/config.py`) specifies the location of the
saved checkpoint, and is shared for both the `subgraph_matching` and `subgraph_mining` models.
1. `python3 -m subgraph_mining.decoder --dataset=enzymes --node_anchored`

Full configuration options can be found in `decoder/config.py`. SPMiner also shares the
configurations of NeuroMatch `subgraph_matching/config.py` since it's used as a subroutine.

## Analyze results
- Analyze the order embeddings after training the encoder: `python3 -m analyze.analyze_embeddings --node_anchored`
- Count the frequencies of patterns generated by the decoder: `python3 -m analyze.count_patterns --dataset=enzymes --out_path=results/counts.json --node_anchored`
- Analyze the raw output from counting: `python3 -m analyze.analyze_pattern_counts --counts_path=results/`

## Dependencies
The library uses PyTorch and [PyTorch Geometric](https://github.com/rusty1s/pytorch_geometric) to implement message passing graph neural networks (GNN). 
It also uses [DeepSNAP](https://github.com/snap-stanford/deepsnap), which facilitates easy use
of graph algorithms (such as subgraph operation and matching operation) to be performed during training for every iteration, 
thanks to its synchronization between an internal graph object (such as a NetworkX object) and the Pytorch Geometric Data object.

Detailed library requirements can be found in requirements.txt

