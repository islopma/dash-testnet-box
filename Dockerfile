# dash-testnet-box docker image

FROM ubuntu
LABEL maintainer="Sean Lavine <lavis88@gmail.com>"

# install make
RUN apt-get update && \
	apt-get install --yes make wget

# create a non-root user
RUN adduser --disabled-login --gecos "" tester

# run following commands from user's home directory
WORKDIR /home/tester

ENV DASH_CORE_VERSION "0.17.0.3"

# download and install dash binaries
RUN mkdir tmp \
	&& cd tmp \
	"https://github.com/dashpay/dash/releases/download/v${DASH_CORE_VERSION}/dashcore-${DASH_CORE_VERSION}-x86_64-linux-gnu.tar.gz"
	&& wget "https://github.com/dashpay/dash/releases/download/v${DASH_CORE_VERSION}/dashcore-${DASH_CORE_VERSION}-x86_64-linux-gnu.tar.gz" \
	&& tar xzf "dashcore-${DASH_CORE_VERSION}-x86_64-linux-gnu.tar.gz" \
	&& cd "dashcore-${DASH_CORE_VERSION}/bin" \
	&& install --mode 755 --target-directory /usr/local/bin *

# clean up
RUN rm -r tmp

# copy the testnet-box files into the image
ADD . /home/tester/dash-testnet-box

# make tester user own the dash-testnet-box
RUN chown -R tester:tester /home/tester/dash-testnet-box

# color PS1
RUN mv /home/tester/dash-testnet-box/.bashrc /home/tester/ && \
	cat /home/tester/.bashrc >> /etc/bash.bashrc

# use the tester user when running the image
USER tester

# run commands from inside the testnet-box directory
WORKDIR /home/tester/dash-testnet-box

# expose two rpc ports for the nodes to allow outside container access
EXPOSE 19001 19011
CMD ["/bin/bash"]
