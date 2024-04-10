FROM pytorch/pytorch:1.4-cuda10.1-cudnn7-runtime

WORKDIR /spminer

RUN apt-get update && apt-get install -y git && apt-get install -y libfreetype6-dev libxft-dev

RUN git clone https://github.com/maTh51/neural-subgraph-learning-GNN /spminer

RUN pip install -r requirements.txt

RUN pip install torch-geometric \
torch-sparse==latest+cu101 \
torch-scatter==latest+cu101 \
torch-cluster==latest+cu101 \
-f https://pytorch-geometric.com/whl/torch-1.4.0.html

COPY . .

CMD ["python3", "-m", "subgraph_mining.decoder", "--dataset=cox2", "--node_anchored"]  
