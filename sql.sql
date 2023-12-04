-- ESX
ALTER TABLE `users`
ADD nextcm INT;

ALTER TABLE `users`
ALTER nextcm SET DEFAULT 0;


-- QB
ALTER TABLE `players`
ADD nextcm INT;

ALTER TABLE `players`
ALTER nextcm SET DEFAULT 0;
