# D3 Icy Veins scrap

**Build** the image with an *Alpine Ruby* with *Nokogiri*
```bash
docker build . -t ruby2.6_nokogiri
```

**Execute** the script with a given D3 build from *Icy veins*
```bash
docker run --rm -it --name icy_veins -v $(pwd):/usr/src/app ruby2.6_nokogiri ruby icy_veins.rb --link https://www.icy-veins.com/d3/monk-tempest-rush-build-with-sunwuko -v
```