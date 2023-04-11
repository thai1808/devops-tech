FROM alpine:latest

# Copy script to container
COPY ./check_content.sh /usr/local/bin/check_content
RUN chmod +x /usr/local/bin/check_content

# Set default file path
ENV FILE_PATH=/etc/hosts

# Set entrypoint
#ENTRYPOINT ["check_content"]
ENTRYPOINT ["/usr/local/bin/check_content"]

# Set default command
CMD ["/etc/hosts"]
