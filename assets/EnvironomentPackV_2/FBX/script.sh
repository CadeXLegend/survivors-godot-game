for file in *.fbx.import; do
    sed -i 's/nodes\/root_scale=[0-9.]\+/nodes\/root_scale=0.06/' "$file"
    echo "Fixed: $file"
done
