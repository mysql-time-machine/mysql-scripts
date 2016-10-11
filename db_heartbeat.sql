-- Create the table
CREATE TABLE IF NOT EXISTS db_heartbeat (
    server_id int unsigned NOT NULL,
    csec bigint unsigned DEFAULT NULL,
    PRIMARY KEY (server_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Insert the initial row
INSERT INTO db_heartbeat VALUES ( @@global.server_id, 100 * UNIX_TIMESTAMP(NOW(2)) );

-- Create the event to update this row every 1s
DELIMITER $$

CREATE
  DEFINER=`root`@`localhost`
  EVENT `db_heartbeat`
  ON SCHEDULE EVERY 1 SECOND
  ON COMPLETION PRESERVE ENABLE
DO
BEGIN
  DECLARE result INT;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  SET innodb_lock_wait_timeout = 1;
  SET result = GET_LOCK( 'db_heartbeat', 0 );
  IF result = 1 THEN
    UPDATE db_heartbeat SET csec=100*UNIX_TIMESTAMP(NOW(2)) WHERE server_id = @@global.server_id;
    SET result = RELEASE_LOCK( 'db_heartbeat' );
  END IF;
END$$

DELIMITER ;
