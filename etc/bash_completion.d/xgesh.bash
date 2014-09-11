_xgesh_ip() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=( $(compgen -W "accept_list negbal_list snat" -- $cur) )
}
complete -F _xgesh_ip xgesh ip

_xgesh_mac() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=( $(compgen -W "set remove" -- $cur) )
}
complete -F _xgesh_mac xgesh mac

_xgesh_policy() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=( $(compgen -W "set remove" -- $cur) )
}
complete -F _xgesh_policy xgesh policy

_xgesh_session() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=( $(compgen -W "list info test dump disconnect remove" -- $cur) )
}
complete -F _xgesh_session xgesh session

_xgesh()
{
	local prev
	COMPREPLY=()
	local cur=${COMP_WORDS[COMP_CWORD]}
	# cur=`_get_cword`
	prev=${COMP_WORDS[COMP_CWORD-1]}
	case $prev in
		@(ip))
		_xgesh_ip
		return 0
		;;
		@(mac))
		_xgesh_mac
		return 0
		;;
		@(help))
		_xgesh_help
		return 0
		;;
		@(policy))
		_xgesh_policy
		return 0
		;;
		@(session))
		_xgesh_session
		return 0
		;;
	esac

	COMPREPLY=( $(compgen -W "ip help session mac policy" -- $cur) )
}
complete -F _xgesh xgesh
