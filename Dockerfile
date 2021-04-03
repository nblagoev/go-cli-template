FROM photon:4.0

COPY ./dist/linux-amd64/gotmpl /usr/local/opt/gotmpl/bin/
#COPY ./conf/ /usr/local/opt/gotmpl/
RUN chmod +x /usr/local/opt/gotmpl/bin/gotmpl && \
	ln -s /usr/local/opt/gotmpl/bin/gotmpl /usr/local/bin/gotmpl

ENTRYPOINT ["/usr/local/bin/gotmpl"]
CMD [ "version", "-b" ]
