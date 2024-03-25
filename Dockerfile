
# Use the Jupyter scipy notebook as a parent image
FROM quay.io/jupyter/scipy-notebook:latest

# Use root to install additional packages
USER root

# Install any additional system packages required for your kernels here
# Example: RUN apt-get update && apt-get install -y package-name
# Install system dependencies
RUN apt-get update && apt-get install -y curl nodejs npm

# Install Rust and the EvCxR Jupyter kernel for Rust
USER root

# Install wget and tar if not already available (optional, depending on your base image)
RUN apt-get update && apt-get install -y wget tar

# Download and extract the pre-built evcxr_jupyter binary
RUN wget https://github.com/evcxr/evcxr/releases/download/v0.17.0/evcxr_jupyter-v0.17.0-x86_64-unknown-linux-gnu.tar.gz -O evcxr_jupyter.tar.gz \
    && tar -xzf evcxr_jupyter.tar.gz -C /tmp \
    && mv /tmp/evcxr_jupyter-v0.17.0-x86_64-unknown-linux-gnu/evcxr_jupyter /usr/local/bin \
    && chmod +x /usr/local/bin/evcxr_jupyter

# Install the evcxr_jupyter kernel
RUN evcxr_jupyter --install

# Clean up
RUN rm evcxr_jupyter.tar.gz \
    && rm -r /tmp/evcxr_jupyter-v0.17.0-x86_64-unknown-linux-gnu

    
# Install iJavaScript for JavaScript and TypeScript
RUN npm install -g tslab \
    && tslab install --version \
    && tslab install


# make sure jovyan owns its files
# Create the 'jovyan' group if it doesn't already exist and add 'jovyan' user to it
RUN groupadd -f jovyan && usermod -aG jovyan jovyan

# Now change the ownership
RUN chown -R jovyan:jovyan /home/jovyan

# Switch back to jovyan to avoid running as root
USER jovyan

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Update PATH for all subsequent instructions
ENV PATH="/home/jovyan/.cargo/bin:${PATH}"
# Install additional Jupyter kernels or Python packages
# Example: RUN pip install package-name
# To install a new Jupyter kernel:
# RUN pip install ipykernel
# RUN python -m ipykernel install --user --name=mykernel

# Copy files or directories from the host to the container
# COPY ./localpath /home/jovyan/work/localpath

# Expose the port Jupyter will run on
EXPOSE 8888
