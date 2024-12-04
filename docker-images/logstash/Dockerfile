# Use the official Logstash image from Elastic
FROM docker.elastic.co/logstash/logstash:8.15.0

# Copy the Logstash configuration file into the container
COPY logstash.conf /usr/share/logstash/pipeline/logstash.conf

# Optional: Install additional plugins if necessary
RUN logstash-plugin install logstash-filter-json

# Expose the port Logstash is listening on
EXPOSE 5044

# Start Logstash using the configuration file
CMD ["logstash", "-f", "/usr/share/logstash/pipeline/logstash.conf"]
