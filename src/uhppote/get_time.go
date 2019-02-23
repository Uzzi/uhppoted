package uhppote

import (
	"encoding/binary"
	"uhppote/messages"
	"uhppote/types"
)

func (u *UHPPOTE) GetTime() (*types.DateTime, error) {
	cmd := make([]byte, 64)

	cmd[0] = 0x17
	cmd[1] = 0x32
	cmd[2] = 0x00
	cmd[3] = 0x00

	binary.LittleEndian.PutUint32(cmd[4:8], u.SerialNumber)

	reply, err := u.Execute(cmd)

	if err != nil {
		return nil, err
	}

	result, err := messages.NewGetTime(reply)

	if err != nil {
		return nil, err
	}

	return &result.DateTime, nil
}
