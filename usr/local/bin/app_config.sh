#config_file=$1
#config_cache=${config_file%%.*}
config_cache=/cfg/config.cache
config_files=('/cfg/channel.config' '/cfg/main.config')
old_config=/cfg/config


convert_config() {
	[ ! -f "$1" ] && return 0
	while IFS== read var val t; do
		[ ${var:--} = '-' ] && continue
		echo ${var//./_}=${val};
	done < $1 >> $config_cache 
}

convert_old_config() {
	[ ! -f "$old_config" ] && return 0
	while IFS== read var val t; do
		[ "${var:--}" = '-' ] && continue
		echo -n ${var//./_} | sed -e "s/-/_/g; s/\./_/g; s/\['/_/g; s/'\]//g; s/_\+/_/g"
		echo =${val}
	done < $old_config | grep -v '=$' >> $config_cache
}


need_recache=0
if [ ! -f "$config_cache" ]; then
	need_recache=$((need_recache+1))
	:>$config_cache
fi

for config_file in $config_files; do
	[ "$need_recache" != "0" ] && break
	if [ "$(stat -c %Y $config_file)" -gt "$(stat -c %Y $config_cache)" ]; then
		need_recache=$((need_recache+1))
	fi
done

[ "$(stat -c %Y $old_config)" -gt "$(stat -c %Y $config_cache)" ] && need_recache=$((need_recache+1))

if [ "$need_recache" != "0" ]; then
	:>$config_cache
	for config_file in $config_files; do
		convert_config $config_file
	done
	convert_old_config
fi

. $config_cache