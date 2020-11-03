# CSIOR: Circle-Surface Intersection Ordered Resampling

CSIOR is an algorithm that is capable of generating an equilateral triangular mesh, i.e., a mesh with quasi-equilateral facets, while preserving the object shape and local geometric properties as corrugations or relief patterns. Also, CSIOR is distinguished by its intrinsic capacity of producing an ordered mesh, whereby the triangular facets are arranged in polar fashion with respect to a seed point. 

#### Publications
- **Computer Aided Geometric Design** [[link](https://doi.org/10.1016/j.cagd.2020.101837)]
- International Conference on Image Processing (ICIP 2020) [[link](https://doi.org/10.1109/ICIP40778.2020.9190919)]
- International Conference on Smart Multimedia (ICSM 2019) [[link](https://doi.org/10.1007/978-3-030-54407-2_3)]
- Smart Tools and Apps in computer Graphics (STAG 2019) [[link](https://doi.org/10.2312/stag.20191372)]

# How-to
### Installation
- Clone the repository
```bash
git clone https://github.com/torto85/CSIOR.git
cd CSIOR
```
- Install [Fast Marching Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/6110-toolbox-fast-marching) (this dependency is required to solve some critical cases)


### Test script
To test the algorithm on a mesh run the following command 
```matlab
test_CSIOR
```
The script will resample the mesh saved in `towel1_2_a_s10000a.off`  and generate some illustrative figures.


### Run
To resample a mesh manifold run:
```matlab
[ vertex, face, rings ] = CSIOR ( original_vertex, original_face )
```
where `original_vertex` and `original_face` are the set of vertices and facets of the original mesh to be resampled, while `vertex` `face` define the resampled mesh. `rings` will provide a structure where each component define an **ordered concentric ring** propagated from the *seed point*. Please refer to our [paper](https://doi.org/10.1016/j.cagd.2020.101837) for more details.

To chose the desired  *facet edge lenght* use `edge_lenght`:
```matlab
[ vertex, face, rings ] = CSIOR ( original_vertex, original_face, edge_lenght )
```

To chose the *initial seed point* use `initial_vertex` defined as an index in the `original_vertex` array: 
```matlab
[ vertex, face, rings ] = CSIOR ( original_vertex, original_face, edge_length, initial_vertex )
```

# Citation
If you find this code useful, please consider citing our papers
```
@article{tortorici2020101837,
title = "CSIOR: Circle-Surface Intersection Ordered Resampling",
journal = "Computer Aided Geometric Design",
volume = "79",
pages = "101837",
year = "2020",
doi = "https://doi.org/10.1016/j.cagd.2020.101837",
author = "Claudio Tortorici and Mohamed Kamel Riahi and Stefano Berretti and Naoufel Werghi",
}
```
```
@inproceedings{9190919,
  author={C. {Tortorici} and N. {Werghi} and S. {Berretti}},
  booktitle={2020 IEEE International Conference on Image Processing (ICIP)}, 
  title={CSIOR: An Algorithm For Ordered Triangular Mesh Regularization}, 
  year={2020},
  pages={2696-2700},
  doi={10.1109/ICIP40778.2020.9190919}}
```
